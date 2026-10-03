---
name: kilio-nouvelle-entree
description: "Créer une nouvelle entrée dans l'application Kilio (tâche ou note) directement depuis le chat, sans ouvrir l'app. Utiliser quand l'utilisateur demande d'ajouter/créer une tâche, un rappel, une note ou une checklist dans Kilio (ex: \"ajoute une tâche dans Kilio\", \"note-moi ça dans Kilio\", \"crée-moi un rappel\"). Sert aussi pour les rappels (\"rappelle-moi\", \"mets un rappel\")."
metadata:
  origin: kilaskills
---

# Nouvelle entrée Kilio

Crée directement en base de données une nouvelle tâche ou une nouvelle note pour
l'application Kilio, via le serveur MCP Supabase (outils `mcp__Supabase__execute_sql`
et compagnie). Kilio n'expose pas d'API publique de création (seules des Server
Actions Next.js internes existent) : ce skill reproduit leur logique de validation
directement en SQL, sur la base du projet Supabase du même nom.

- **Projet Supabase** : `kilio` — `project_id = "vsmtkopkqasrdnjceegp"`. Si ce projet
  n'est pas trouvé (`mcp__Supabase__list_projects`), demander confirmation avant de
  continuer plutôt que de deviner un autre projet.
- Utilise toujours des requêtes SQL paramétrées mentalement (échapper les apostrophes
  françaises en les doublant, ex: `l''appartement`) — ne jamais interpoler du texte
  utilisateur sans y penser, même si `execute_sql` ne prend qu'une chaîne brute.
- Après insertion, confirme à l'utilisateur en une phrase ce qui a été créé (titre,
  liste ou type, échéance si présente), sans ouvrir l'app ni faire de commit/push
  (ce skill ne touche jamais au code du dépôt Kilio, seulement à ses données).

## 1. Créer une tâche

Table `public.taches`. Colonnes obligatoires : `titre` (text), `liste_id` (uuid,
FK vers `listes_taches`). Toutes les autres ont un défaut ou acceptent `null`.

1. **Résoudre `liste_id`** : si l'utilisateur nomme une liste, chercher son id par
   nom (`select id from listes_taches where nom ilike '<nom>'`). Sinon, ou si la
   liste n'existe pas, utiliser la liste `Général` (créer une nouvelle ligne dans
   `listes_taches` seulement si `Général` lui-même n'existe pas, ce qui ne devrait
   pas arriver).
2. **Calculer `ordre`** : `select coalesce(max(ordre), -1) + 1 from taches where liste_id = '<liste_id>'`
   pour insérer la tâche en fin de liste (même logique que `createTache`).
3. **Valeurs par défaut identiques aux Server Actions** (`src/app/actions/taches.ts`) :
   - `priorite` : un des `aucune | basse | moyenne | haute`, défaut `aucune`.
   - `echeance` : date `YYYY-MM-DD` si demandée, sinon `null` — sauf si la tâche est
     marquée "programme du jour" (`programme_jour = true`), auquel cas elle prend la
     date du jour par défaut.
   - `heure` / `heure_fin` : format `HH:MM`, uniquement si `toute_la_journee = false`.
     Si `heure_fin` est fournie, elle doit être strictement après `heure`.
   - `toute_la_journee` : `false` par défaut.
   - `recurrence_frequence` : un des `quotidien | hebdomadaire | mensuel | annuel`
     ou `null`. `recurrence_fin` n'a de sens qu'accompagnée d'une fréquence.
   - `rappel_minutes` : un des `5 | 15 | 30 | 60 | 1440`, uniquement si une heure est
     définie (ou `1440` seul avec `toute_la_journee = true`, pour un rappel la veille).
     Si la demande contient « rappel », « rappelle-moi » ou « mets-moi un rappel »,
     il ne doit **jamais** rester à `null` (sinon le rappel n'est jamais déclenché) :
     - Valeur par défaut : `5` (rappel 5 minutes avant). La valeur « à l'heure pile »
       (`0`) n'est pas acceptée : la contrainte `taches_rappel_minutes_check` de la
       base n'autorise que `5 | 15 | 30 | 60 | 1440`.
     - Si l'utilisateur précise un délai (« 1 h avant », « la veille »), l'utiliser :
       `5`, `15`, `30`, `60` ou `1440`.
     - Rappel sans heure : ne pas inventer d'heure. Soit poser la question, soit, si
       seule une date est donnée, `toute_la_journee = true` avec `rappel_minutes = 1440`.
     - Exemple : « Rappelle-moi lundi à 10 h de faire une commande » → `echeance` = date
       du lundi, `heure` = `10:00`, `rappel_minutes` = `5` (valeur par défaut ci-dessus).
   - `notes` : texte libre optionnel (`null` si absent), distinct du contenu d'une
     "note" Kilio — c'est juste un champ de description sur la tâche.
4. Insérer :
   ```sql
   insert into taches (titre, liste_id, ordre, echeance, heure, heure_fin,
                        priorite, programme_jour, toute_la_journee,
                        recurrence_frequence, recurrence_fin, rappel_minutes, notes)
   values ('<titre>', '<liste_id>', <ordre>, <echeance|null>, <heure|null>,
           <heure_fin|null>, '<priorite>', <programme_jour>, <toute_la_journee>,
           <recurrence_frequence|null>, <recurrence_fin|null>, <rappel_minutes|null>,
           <notes|null>)
   returning id, titre;
   ```
5. Ne jamais deviner un tag : si l'utilisateur en mentionne un, résoudre son id dans
   `tags` (créer la ligne si absente) puis insérer dans `taches_tags (tache_id, tag_id)`.
   Sinon, ignorer les tags.

## 2. Créer une note

Table `public.notes`. Colonnes obligatoires : `titre` (text), `contenu` (text,
uniquement pour `type = 'texte'` — une checklist porte son contenu dans
`note_items`, pas dans `notes.contenu`, qui doit alors être une chaîne vide `''`).

1. Déterminer `type` : `'texte'` (par défaut) ou `'checklist'` si l'utilisateur
   décrit une liste d'éléments à cocher.
2. `couleur` : `null` sauf demande explicite d'une couleur (vérifier qu'elle existe
   dans la palette du projet — en cas de doute, laisser `null` plutôt qu'inventer
   une valeur).
3. **Note texte** :
   ```sql
   insert into notes (titre, contenu, type, couleur)
   values ('<titre>', '<contenu>', 'texte', <couleur|null>)
   returning id, titre;
   ```
4. **Checklist** : insérer la note avec `contenu = ''` et `type = 'checklist'`, puis
   un item par ligne de la liste demandée par l'utilisateur, avec `position`
   croissante à partir de 0 :
   ```sql
   insert into notes (titre, contenu, type, couleur)
   values ('<titre>', '', 'checklist', <couleur|null>)
   returning id;

   insert into note_items (note_id, libelle, position)
   values ('<note_id>', '<libelle_1>', 0), ('<note_id>', '<libelle_2>', 1), ...;
   ```

## Garde-fous

- Si un champ obligatoire manque (titre vide, liste introuvable et pas de liste par
  défaut, etc.), poser la question à l'utilisateur plutôt que d'insérer une valeur
  inventée.
- Ne jamais modifier ou supprimer une tâche/note existante avec ce skill : il ne
  gère que la création. Pour toute autre opération, renvoyer vers l'application.
- Ce skill ne fait ni commit ni push : il agit uniquement sur les données de
  production Kilio via Supabase, jamais sur le code du dépôt.
