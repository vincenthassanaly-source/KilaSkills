---
name: kilio-pharmacie-ajout
description: "Ranger dans le module Pharmacie de Kilio une info apprise (cours, molécule, conseil, interaction…) dictée en vrac dans le chat : Claude la reformule en notions atomiques, la classe dans matière → chapitre, colore systématiquement le contenu (logique de couleurs choisie par Claude : niveaux, catégories ou étapes), crée les cartes de révision et écrit en base via Supabase. Utiliser quand l'utilisateur dit « j'ai appris que… », « retiens ça en pharmacie », « ajoute ça à mes cours de pharma », ou dicte une connaissance de pharmacie à mémoriser."
metadata:
  origin: kilio
---

# Ajout Pharmacie (Kilio)

Range une info dictée en vrac dans le module **Pharmacie** de Kilio, directement en base
via le serveur MCP Supabase (`mcp__Supabase__execute_sql`). Le module est décrit dans
`src/app/(app)/pharmacie/` ; ce skill n'écrit jamais dans le code du dépôt, seulement dans
les données.

- **Projet Supabase** : `kilio` — `project_id = "vsmtkopkqasrdnjceegp"`. Si introuvable
  (`mcp__Supabase__list_projects`), demander avant de continuer.
- Échapper les apostrophes en les doublant (`l''effet`). Ne jamais interpoler du texte sans y penser.
- Tables : `pharma_matieres`, `pharma_chapitres`, `pharma_notions`, `pharma_cartes`,
  `pharma_historique`. L'utilisateur ne garde **que la version reformulée** (pas de journal brut).
  Pas de suivi de source ni de vérification web : c'est son cahier personnel.

## Règles de fond

1. **N'ajouter aucun fait que l'utilisateur n'a pas donné.** Reformuler, structurer, clarifier
   la formulation ; ne jamais compléter avec des connaissances médicales propres (posologies,
   contre-indications…). Domaine santé : mieux vaut une notion plus courte qu'une invention.
2. **Notions atomiques** : une idée = une notion (titre court + contenu de 1 à 4 phrases + tags).
   Une dictée qui contient trois idées donne trois notions.
3. **Compléter avant de créer** : si une notion proche existe déjà, la mettre à jour ou la
   compléter plutôt que de créer un doublon.
4. Texte seul : pas de tableau, pas d'image.
5. Tags : minuscules, 1 à 5 par notion (molécule, classe, pathologie…).

## Déroulé

### 1. Lire l'arborescence et chercher les notions proches

```sql
select m.id as matiere_id, m.nom as matiere, c.id as chapitre_id, c.nom as chapitre,
       (select count(*) from pharma_notions n where n.chapitre_id = c.id) as notions
from pharma_matieres m
left join pharma_chapitres c on c.matiere_id = m.id
order by m.ordre, m.nom, c.ordre, c.nom;
```

Pour chaque idée, chercher les notions proches (tolère accents, casse, fautes) :

```sql
select notion_id, titre, contenu, chapitre_nom, matiere_nom, score
from pharma_rechercher('<mot-clé principal>') limit 5;
```

### 2. Décider du rangement

- **Chapitre existant adapté** : y ranger (automatique).
- **Aucun chapitre adapté** : créer le chapitre (et la matière si besoin). Claude gère
  l'arborescence seul : créer, renommer, fusionner, déplacer sans demander, puis **le dire
  à l'utilisateur après coup** dans sa réponse. Préférer peu de matières larges
  (Pharmacologie, Galénique, Conseil officinal, Physiologie…) et des chapitres précis.
- Noms courts, sans doublon (index unique insensible à la casse).

```sql
-- matière (si absente)
insert into pharma_matieres (nom, ordre)
values ('<nom>', (select coalesce(max(ordre), -1) + 1 from pharma_matieres))
returning id;

-- chapitre (si absent)
insert into pharma_chapitres (matiere_id, nom, ordre)
values ('<matiere_id>', '<nom>',
        (select coalesce(max(ordre), -1) + 1 from pharma_chapitres where matiere_id = '<matiere_id>'))
returning id;
```

### 3. Écrire les notions

Nouvelle notion :

```sql
insert into pharma_notions (chapitre_id, titre, contenu, tags, ordre)
values ('<chapitre_id>', '<titre>', '<contenu>', array['<tag1>','<tag2>'],
        (select coalesce(max(ordre), -1) + 1 from pharma_notions where chapitre_id = '<chapitre_id>'))
returning id;
```

Compléter une notion existante (fusionner l'info, garder le contenu clair, sans répétition) :

```sql
update pharma_notions
set contenu = '<contenu fusionné>', tags = array['<tags fusionnés>'], updated_at = now()
where id = '<notion_id>';
```

## Couleurs

Toute notion est colorée, sans exception. L'écrire sur plusieurs lignes et colorer chaque ligne
avec une balise en DÉBUT de ligne : `[couleur] texte`. 12 couleurs autorisées, en minuscules,
sans accent, en un seul mot. Toute autre balise s'affiche comme du texte normal.

Couleurs à sens fixe (seuils et niveaux) :

- bleu = bas / insuffisant (ex. hypoglycémie)
- vert = normal / cible
- orange = à surveiller (ex. prédiabète)
- rouge = danger / pathologique (ex. diabète, hypoglycémie sévère)
- gris = repère, conversion ou contexte neutre

Couleurs de catégorie : violet, rose, jaune, turquoise, marron, indigo, lime. Elles n'ont AUCUN
sens fixe : elles servent à distinguer des catégories, produits ou familles (ex. un type de
pansement par couleur). Claude choisit l'attribution, mais la garde cohérente au sein d'un
chapitre : une même catégorie garde la même couleur d'une notion à l'autre, et deux catégories
différentes n'en partagent pas. Ne pas utiliser ces couleurs pour un niveau de gravité (réservé
aux 5 couleurs à sens fixe) ni mélanger les deux usages dans une même notion.

Claude choisit seul la logique d'attribution la plus pertinente pour le contenu, sans poser la
question, et la garde **cohérente au sein d'un même chapitre** (même couleur = même sens d'une
notion à l'autre). Logiques possibles :

- **Niveaux ou seuils** : bleu = bas / insuffisant, vert = normal / cible, orange = à surveiller,
  rouge = danger / pathologique, gris = repère, conversion ou contexte neutre.
- **Familles, catégories ou produits** : une couleur par catégorie. Ex. pansements : gris =
  protection basique, bleu = plaies sèches ou superficielles, vert = exsudat modéré, orange =
  exsudat important, rouge = plaie infectée ou malodorante.
- **Étapes ou stades** : une couleur par étape, dans l'ordre de gravité ou de progression.

Règles :

- Une seule balise par ligne, au tout début, suivie d'un espace puis du texte. Pas de segment
  coloré au milieu d'une phrase.
- Le texte de la ligne reste explicite (« Normale : 0,70 à 1,10 g/L », « Diabète : ≥ 1,26 g/L ») :
  la couleur ne remplace jamais le libellé.
- Les couleurs ne servent qu'à classer ce qui est dit : n'inventer ni seuil, ni niveau, ni
  catégorie que l'utilisateur n'a pas donné (règle de fond 1).
- Notion sans niveaux ni catégories évidents (définition, mécanisme, conseil) : colorer la
  première ligne (titre ou contexte) avec la couleur de sa catégorie dans le chapitre, le reste
  du contenu en texte simple.
- Séparer les lignes par un retour à la ligne dans la valeur SQL (littéral multi-lignes,
  apostrophes doublées). Exemples :

```sql
-- logique « niveaux » (chapitre Diabète)
insert into pharma_notions (chapitre_id, titre, contenu, tags, ordre)
values ('<chapitre_id>', 'Glycémie à jeun', '[bleu] Hypoglycémie : < 0,70 g/L
[vert] Normale : 0,70 à 1,10 g/L
[orange] Prédiabète : 1,10 à 1,25 g/L
[rouge] Diabète : ≥ 1,26 g/L', array['glycémie'], <ordre>);

-- logique « catégories » (chapitre Pansements et plaies, matière Conseil officinal) :
-- uniquement les catégories et libellés donnés par l'utilisateur dans sa dictée
insert into pharma_notions (chapitre_id, titre, contenu, tags, ordre)
values ('<chapitre_id>', 'Choix du pansement selon la plaie', '[gris] Protection basique
[bleu] Plaies sèches ou superficielles
[vert] Exsudat modéré
[orange] Exsudat important
[rouge] Plaie infectée ou malodorante', array['pansement','plaie'], <ordre>);
```

- Les cartes de révision peuvent utiliser les mêmes balises dans `reponse` quand la réponse
  est un niveau ou une catégorie colorée (ex. « [rouge] Diabète : ≥ 1,26 g/L »), mais restent
  en texte simple sinon.
- Pour repérer un doublon avec `pharma_rechercher`, chercher sur un mot du texte : les balises
  n'ont aucun effet sur la recherche dans l'app.

### 4. Créer les cartes de révision (automatique)

1 à 3 cartes par notion **nouvelle ou enrichie** : question courte et autonome, réponse brève
tirée uniquement du contenu de la notion. Une carte = un fait. Pas de « vrai/faux ».
Ne pas recréer une carte déjà présente pour la même notion (vérifier
`select question from pharma_cartes where notion_id = '<id>'`).

```sql
insert into pharma_cartes (notion_id, question, reponse)
values ('<notion_id>', '<question>', '<réponse>');
```

Les colonnes de répétition espacée ont des défauts (carte à réviser tout de suite) : ne pas les fournir.

### 5. Réorganisations : les journaliser

À chaque création de matière ou de chapitre, renommage, fusion ou déplacement décidé par Claude :

```sql
insert into pharma_historique (action, cible, details)
values ('<creation|renommage|fusion|deplacement>', '<Matière › Chapitre>',
        '{"avant": "...", "apres": "..."}'::jsonb);
```

Pour fusionner deux chapitres : déplacer d'abord les notions
(`update pharma_notions set chapitre_id = '<cible>' where chapitre_id = '<source>'`),
vérifier que le chapitre source est vide, puis seulement le retirer.

### 6. Répondre

Une à trois phrases, sans recopier le contenu :

- où c'est rangé (`Pharmacologie › Antihypertenseurs`), combien de notions et de cartes ;
- toute réorganisation faite (« j'ai créé le chapitre X », « j'ai fusionné Y dans Z ») ;
- la logique de couleurs choisie, en une phrase (« couleurs par niveaux de gravité », « une couleur par type de pansement »…) ;
- si la dictée **contredit** une notion existante, l'écrire clairement (« ça contredit la
  notion "…" que j'ai gardée / remplacée ») : la contradiction est signalée dans le chat, pas
  stockée.

## Garde-fous

- Ne jamais supprimer une notion ou une matière sur simple soupçon : suppression seulement si
  l'utilisateur la demande ; sinon renvoyer vers l'app (« Modifier » sur la notion).
- Si l'info est trop vague pour être une notion (pas d'idée précise), poser une question.
- Aucun commit, aucun push : ce skill n'agit que sur les données Supabase.
