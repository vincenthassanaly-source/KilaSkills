---
name: kilio-huiles-essentielles
description: "Ajouter ou corriger une huile essentielle dans le module Pharmacie de Kilio, directement en base via Supabase (table pharma_he_huiles) puis resynchroniser ses cartes de révision. Utiliser quand l'utilisateur dit « ajoute l'huile essentielle de… », « ajoute <huile> à mes huiles essentielles », ou dicte en vrac une huile essentielle avec son nom, ses indications, ses précautions. Claude ne range que ce qui est dicté, complète une fiche existante plutôt que de créer un doublon, et n'écrit jamais dans le code du dépôt."
metadata:
  origin: kilio
---

# Huiles essentielles (Kilio)

Ajoute ou corrige une huile essentielle dans le module **Pharmacie** de Kilio, directement en
base via le serveur MCP Supabase (`mcp__Supabase__execute_sql`). Ce skill n'écrit jamais dans le
code du dépôt, seulement dans les données.

- **Projet Supabase** : `kilio` — `project_id = "vsmtkopkqasrdnjceegp"`. Si introuvable
  (`mcp__Supabase__list_projects`), demander avant de continuer.
- Échapper les apostrophes en les doublant (`l''huile`). Texte seul, pas de photo.

## Tables

`pharma_he_huiles` :

- `id` uuid (défaut), `nom_fr` text NOT NULL, `nom_latin`, `famille`, `partie_distillee`, `chemotype` : text
- `indications` text[], `proprietes` text[] : tags libres, vocabulaire cohérent d'une huile à l'autre
- `voies` text[] parmi : `orale`, `cutanee`, `diffusion`, `inhalation`, `bain`.
  **« Comestible » n'est PAS un champ** : c'est la présence de `orale` dans `voies`.
- `dermocaustique` boolean, `photosensibilisante` boolean
- `precautions` text[] parmi : `grossesse`, `allaitement`, `enfant`, `epilepsie`, `asthme`,
  `hypertension`, `anticoagulants` (contraintes CHECK en base : toute autre valeur est rejetée)
- `precautions_details`, `dosage`, `mode_emploi`, `notes`, `sources` : text
- `created_at`, `updated_at` timestamptz : mettre `updated_at = now()` à chaque UPDATE

`pharma_cartes` : cartes de révision. Pour une huile : `huile_id` (FK vers `pharma_he_huiles`,
ON DELETE CASCADE) et `he_type`, avec contrainte UNIQUE (`huile_id`, `he_type`).

## Règles de fond

1. **N'ajouter AUCUN fait que l'utilisateur n'a pas donné.** Domaine santé : ne jamais compléter
   avec ses propres connaissances (indications, voies, dilutions, contre-indications, nom latin…).
   Un champ non dicté reste vide (null ou tableau vide). `voies` et `precautions` vides =
   **inconnu**, jamais « sûr ».
2. **Mapper ce qui est dit vers les valeurs autorisées** : « on peut l'avaler » → `orale`,
   « interdit aux femmes enceintes » → `grossesse`, « à respirer » → `inhalation`. Si une
   précaution dictée n'a pas de case (ex. « déconseillée aux hypotendus »), la mettre dans
   `precautions_details`, mot pour mot reformulé.
3. **Chercher d'abord une huile proche** (`nom_fr ilike` ou `nom_latin ilike`, tolérant aux
   accents) et la compléter plutôt que créer un doublon ; **dire à l'utilisateur ce qui a été
   fusionné**.
4. **Tags en minuscules**, en réutilisant le vocabulaire existant (`select distinct unnest(indications) …`)
   avant d'en inventer un.
5. Échapper les apostrophes en les doublant. Texte seul, pas de photo.
6. **Après écriture, répondre avec un récapitulatif court** (voir étape 4).

## Déroulé

### 1. Lister les huiles proches et les tags existants

```sql
-- huiles proches (unaccent si l'extension est disponible, sinon ilike simple)
select id, nom_fr, nom_latin, voies, precautions
from pharma_he_huiles
where unaccent(nom_fr) ilike unaccent('%<mot-clé>%')
   or unaccent(coalesce(nom_latin, '')) ilike unaccent('%<mot-clé>%')
order by nom_fr;

-- vocabulaire existant des tags
select distinct unnest(indications) as tag from pharma_he_huiles order by 1;
select distinct unnest(proprietes)  as tag from pharma_he_huiles order by 1;
```

Si `unaccent()` n'existe pas, utiliser `ilike` avec la graphie dictée et une variante sans accent.
Huile proche trouvée → UPDATE (jamais de second INSERT).

### 2. INSERT ou UPDATE de l'huile (avec `RETURNING id`)

Nouvelle huile : ne renseigner que les colonnes dictées.

```sql
insert into pharma_he_huiles
  (nom_fr, nom_latin, indications, proprietes, voies, dermocaustique, photosensibilisante,
   precautions, precautions_details)
values
  ('Lavande vraie', 'Lavandula angustifolia',
   array['stress','sommeil'], array['calmante'],
   array['diffusion','cutanee'], false, false,
   array['grossesse'], 'Déconseillée aux hypotendus.')
returning id;
```

Huile existante : ne modifier que ce que l'utilisateur dicte ; pour un tableau, fusionner sans
doublon et sans perdre l'existant (sauf correction demandée) :

```sql
update pharma_he_huiles
set voies = (select array(select distinct unnest(voies || array['orale']))),
    precautions_details = 'Déconseillée aux hypotendus.',
    updated_at = now()
where id = '<huile_id>'
returning id;
```

Booléens `dermocaustique` / `photosensibilisante` : ne les renseigner que si dit
(sinon laisser la valeur par défaut de la base).

### 3. Resynchroniser les 5 cartes (après chaque INSERT ou UPDATE)

Même logique que l'app (`src/lib/pharmacie/huiles.ts`, fonction `genererCartesHuile`). Cartes
dérivées de la fiche, une par type (`he_type`) :

| he_type | Question | Réponse | Condition |
|---|---|---|---|
| `latin` | Nom latin de l'huile essentielle de <nom_fr> ? | nom_latin | nom_latin renseigné |
| `francais` | Quelle huile essentielle porte le nom latin « <nom_latin> » ? | nom_fr | nom_latin renseigné |
| `indications` | À quoi sert l'huile essentielle de <nom_fr> ? | liste « • … » (une indication par ligne) | indications non vide |
| `voies` | L'huile essentielle de <nom_fr> est-elle comestible, et par quelles voies s'utilise-t-elle ? | « Comestible : oui, par voie orale » ou « Comestible : non, pas de voie orale », puis « Voies : … » | voies non vide |
| `precautions` | Précautions et contre-indications de l'huile essentielle de <nom_fr> ? | lignes « Déconseillée : … », « Dermocaustique : toujours diluée sur la peau », « Photosensibilisante : pas de soleil après application », puis `precautions_details` | au moins une ligne |

Règle de synchronisation :

- **INSERT** des cartes manquantes (avec `huile_id` et `he_type`) ;
- **UPDATE** de `question` / `reponse` si le texte a changé, **SANS toucher aux champs de
  répétition espacée** (`echeance`, `intervalle_jours`, `facilite`, `repetitions`, `dernier_passage`) ;
- **DELETE** des cartes dont le type n'est plus voulu (condition non remplie).

Upsert (une ligne par carte voulue ; ne pas fournir les colonnes de répétition) :

```sql
insert into pharma_cartes (huile_id, he_type, question, reponse)
values
  ('<huile_id>', 'latin',
   'Nom latin de l''huile essentielle de Lavande vraie ?', 'Lavandula angustifolia'),
  ('<huile_id>', 'indications',
   'À quoi sert l''huile essentielle de Lavande vraie ?', '• stress
• sommeil'),
  ('<huile_id>', 'voies',
   'L''huile essentielle de Lavande vraie est-elle comestible, et par quelles voies s''utilise-t-elle ?',
   'Comestible : non, pas de voie orale
Voies : diffusion, cutanée')
on conflict (huile_id, he_type)
do update set question = excluded.question, reponse = excluded.reponse
where (pharma_cartes.question, pharma_cartes.reponse)
      is distinct from (excluded.question, excluded.reponse)
returning he_type;
```

Cartes devenues sans objet (ex. nom_latin retiré, `precautions` vidées) :

```sql
delete from pharma_cartes
where huile_id = '<huile_id>'
  and he_type not in ('latin','indications','voies')  -- types encore voulus
returning he_type;
```

Compter les cartes créées ou modifiées avec les `RETURNING` (le `where … is distinct from` évite
de compter les cartes inchangées).

### 4. Récapitulatif

Court (1 à 4 phrases), sans recopier la fiche ni détailler les cartes :

- huile **créée** ou **mise à jour** (et ce qui a été fusionné avec une huile proche) ;
- **comestible : oui / non / inconnu** (oui si `orale` ∈ voies ; « inconnu » si voies vide) ;
- alertes : dermocaustique, photosensibilisante, précautions notées ;
- nombre de cartes créées ou modifiées.

## Garde-fous

- Ne jamais supprimer une huile sur simple soupçon : suppression seulement si l'utilisateur la
  demande explicitement.
- Valeur dictée hors liste autorisée pour `voies` / `precautions` → la mapper, sinon la mettre
  dans `precautions_details` ou `notes` ; ne jamais tenter une valeur hors contrainte CHECK.
- Aucun commit, aucun push : ce skill n'agit que sur les données Supabase.
