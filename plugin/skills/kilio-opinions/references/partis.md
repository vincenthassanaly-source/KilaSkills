# Partis politiques — procédures et requêtes SQL

Onglet « Partis » du module Opinions de Kilio. Projet Supabase `kilio`
(`vsmtkopkqasrdnjceegp`), via `mcp__Supabase__execute_sql`. Les règles d'équité et de
langage simple de `SKILL.md` s'appliquent à tout ce qui suit.

Les formules et détails techniques de ce fichier sont **pour Claude** : ne pas les
réciter à l'utilisateur, lui expliquer le résultat en mots simples.

## 1. Tables et ce que la base ne vérifie pas

| Table | Colonnes de fond | Vérifié par la base |
|---|---|---|
| `opinions_partis` | `nom`, `sigle` (défaut `''`), `couleur` (défaut `indigo`), `created_at` | `nom` non vide, `nom` unique sans tenir compte de la casse, `couleur` ∈ `indigo, corail, olive, prune, turquoise, ambre, ardoise, rose, vert, violet` |
| `opinions_programmes` | `parti_id` (FK, cascade), `echeance` (texte libre), `date_programme` (date, facultative), `created_at` | `echeance` non vide |
| `opinions_propositions` | `programme_id` (FK, cascade), `"position"`, `theme`, `termes` (jsonb, défaut `[]`), 5 scores, `created_at`, `updated_at` | `position` non vide, scores entre -2 et +2 ou `null`, `termes` est un tableau |
| `opinions_priorites` | `theme` (clé primaire), `niveau`, `updated_at` | `niveau` ∈ `secondaire`, `normal`, `prioritaire` |
| `opinions_idees.proposition_id` | FK nullable vers `opinions_propositions` (`on delete set null`) | — |

**À vérifier soi-même avant d'écrire** (la base ne le fait pas) :
- `sigle` : 12 caractères au plus (`''` s'il n'y en a pas) ;
- `position` d'une proposition : 280 caractères au plus ;
- `couleur` d'un parti : une des 10 teintes. Un parti créé par l'app reçoit la première
  teinte libre ; à l'import, faire de même (requête de l'étape e) et ne jamais choisir
  une teinte pour son sens (aucune n'est liée à un camp) ;
- `termes` d'une proposition : `[{"terme": "TVA", "definition": "…"}]`, 8 entrées au
  plus, `terme` 60 caractères au plus, `definition` 200 au plus (facultative : sans elle
  le mot est seulement surligné). Chaque `terme` doit apparaître **tel quel, en mot
  entier** (casse libre) dans `position`, sans doublon ;
- `theme` d'une proposition : obligatoire, un des 12 slugs
  (`economie, fiscalite, travail, sante, education, immigration, ecologie, securite,
  institutions, international, culture, numerique`) ;
- pas de doublon (même parti, même échéance) : la base l'autorise, donc c'est au skill
  de le refuser (voir l'étape a de l'import) ;
- `opinions_idees.proposition_id` : **ne jamais le remplir** (voir section 9).

Aucune colonne ne stocke de lien ni de citation : une proposition ne garde que le
programme (parti + échéance + date) dont elle vient.

## 2. Grille de notation (identique pour tous les partis)

Mêmes pôles que pour les idées de l'utilisateur : `-2` = pôle « gauche » de l'axe
(économique : État ; sociétal : progressiste ; autorité : libertés ; écologie :
écologie ; identité : ouverture), `+2` = pôle « droite » (marché ; conservateur ;
autorité ; productivisme ; souveraineté). Ce sont des repères d'affichage, pas des
jugements. `null` = axe non concerné, `0` = position centrale **explicite**.

| Score | Quand |
|---|---|
| `±2` | mesure **structurelle et explicite** : création, suppression ou refonte majeure |
| `±1` | ajustement ou orientation modérée |
| `0` | seulement si la proposition prend explicitement une position médiane |
| `null` | l'axe n'est pas clairement touché, **ou doute** (alors le signaler dans « à vérifier ») |

Règles :
1. On note **uniquement ce que dit le texte du programme**, pas la réputation du parti,
   ses alliances, son histoire ou le ton de son discours.
2. Aucun jugement de faisabilité, de sincérité, de coût ou de conséquences : une mesure
   irréaliste se note comme une mesure réaliste.
3. On note **d'après le texte d'origine**, jamais d'après la version simplifiée.
4. Même grille, même rigueur, même niveau de détail pour tous les partis, y compris
   les petits et ceux dont l'utilisateur se sent proche ou éloigné.
5. **Contrôle de cohérence par thème** : après avoir noté plusieurs partis, relire
   d'une seule traite les scores d'un même thème pour tous les partis. Deux mesures
   équivalentes de deux partis doivent avoir le même score ; sinon corriger.
6. Si la recherche est confiée à des sous-agents (un par parti ou par thème), leur
   donner **exactement** les mêmes consignes et la même grille (ce fichier), puis
   faire soi-même le contrôle n°5.

## 3. Écrire une proposition (neutre, simple, ≤ 280 caractères)

- Une mesure concrète par ligne ; pas d'adjectif valorisant ou dévalorisant ; pas de
  longue citation du programme.
- Mots du quotidien, phrases courtes. **Chaque mot technique est défini dans `termes`**,
  pas entre parenthèses dans la phrase : l'app le surligne et affiche la définition au
  tap. Chaque proposition s'affichant seule, redéfinir le mot dans chaque proposition où
  il apparaît, même s'il est déjà défini ailleurs.
- Au plus **deux** mots à définir par proposition ; sinon couper en deux mesures. On peut
  surligner d'autres mots-clés sans définition (4 mots-clés au plus au total).
- Les définitions décrivent ce que la chose *est* ou ce que la mesure *fait*, jamais
  ce qu'il faut en penser. Mot disputé : décrire la mécanique sans avis.
- Contrôler la longueur **avant** d'écrire (requête ci-dessous). Si c'est trop long :
  simplifier la formulation, et signaler la ligne à l'utilisateur. Les définitions de
  `termes` ne comptent pas dans les 280 caractères.
- Vérifier que la phrase simple veut dire **exactement** la même chose que l'original
  (même sens, même score), et que deux mesures équivalentes de deux partis ont la même
  neutralité et le même niveau de simplicité.
- Relire `lexique-simple.md` avant chaque import pour rester cohérent d'un parti à
  l'autre.

Contrôle préalable (lecture seule ; doit renvoyer **0 ligne**) :

```sql
select v.n, length(v."position") as nb_caracteres, v.theme
from (values
  (1, '<position 1>', '<theme 1>'),
  (2, '<position 2>', '<theme 2>')
) as v(n, "position", theme)
where length(v."position") > 280
   or length(btrim(v."position")) = 0
   or v.theme not in ('economie','fiscalite','travail','sante','education','immigration',
                      'ecologie','securite','institutions','international','culture','numerique');
```

Pour connaître la longueur de chaque ligne (et repérer les plus longues), remplacer la
clause `where` par `order by nb_caracteres desc`. Contrôler aussi `sigle` (12 caractères
au plus) avant l'écriture.

## 4. Importer un programme

Déclencheurs : « importe le programme de X », « ajoute les propositions de X ».

**Étape a — Identifier et chercher les doublons** (lecture seule) :

```sql
select pa.id as parti_id, pa.nom, pa.sigle,
       pr.id as programme_id, pr.echeance, pr.date_programme,
       (select count(*) from opinions_propositions p where p.programme_id = pr.id) as nb_propositions
from opinions_partis pa
left join opinions_programmes pr on pr.parti_id = pa.id
where lower(pa.nom) = lower('<nom>') or lower(pa.sigle) = lower('<sigle>')
order by pr.date_programme desc nulls last, pr.created_at desc;
```

- Même parti **et** même échéance déjà en base : demander s'il faut **enrichir**
  (ajouter des propositions au programme existant, section 5) ou **remplacer**
  (supprimer le programme, ce qui supprime ses propositions en cascade, puis
  réimporter). Annoncer le nombre de lignes qui disparaîtraient. Ne jamais créer de
  doublon silencieux.
- Parti existant, échéance différente : nouveau programme pour ce parti.
- Le nom du parti en base et son sigle (12 caractères au plus) se règlent avec
  l'utilisateur s'ils sont ambigus.

**Étape b — Rechercher et lire le programme officiel** : suivre
`recherche-programmes.md`.

**Étape c — Extraire, classer, réécrire** : propositions concrètes ; chacune dans un
des 12 thèmes (si aucun thème ne convient, la signaler au lieu de forcer) ; réécriture
neutre et simple (section 3) ; notation (section 2). Dire clairement si la couverture
est partielle (« 60 mesures sur un programme qui en annonce 100 »).

**Étape d — Tableau de validation**, parti par parti. Pour chaque ligne : n°, thème,
la proposition simple qui sera écrite, une **courte version fidèle du texte d'origine**
(pour vérifier que la simplification n'a rien déformé ; elle n'est **pas** stockée), les
scores par axe (`—` pour non concerné), une colonne « à vérifier ». Distinguer ce qui
vient du texte du programme de ce qui est une inférence (les scores). Ajouter à la fin
la liste des mots expliqués avec leur définition, que l'utilisateur peut corriger.
Voir `exemple-import-parti.md`.

**Étape e — Écriture en un seul lot, après accord explicite uniquement.** Un seul
statement : trouve ou crée le parti, crée le programme, insère les propositions
validées. Caster chaque score (`1::smallint`, `null::smallint`) dans **toutes** les
lignes du `values`, sinon Postgres ne devine pas le type des `null` :

```sql
with p as (
  insert into opinions_partis (nom, sigle, couleur)
  select '<nom>', '<sigle ≤ 12 car. ou vide>',
         coalesce(
           (select c from unnest(array['indigo','corail','olive','prune','turquoise','ambre','ardoise','rose','vert','violet']) with ordinality as t(c, n)
            where c not in (select couleur from opinions_partis) order by n limit 1),
           'indigo')
  where not exists (select 1 from opinions_partis where lower(nom) = lower('<nom>'))
  returning id
), parti as (
  select id from p
  union all
  select id from opinions_partis where lower(nom) = lower('<nom>')
  limit 1
), prog as (
  insert into opinions_programmes (parti_id, echeance, date_programme)
  select id, '<échéance>', <'YYYY-MM-DD'::date | null::date> from parti
  returning id
)
insert into opinions_propositions
  (programme_id, "position", theme, termes,
   score_economique, score_societal, score_autorite, score_ecologie, score_identite)
select prog.id, v."position", v.theme, v.termes::jsonb, v.s_eco, v.s_soc, v.s_aut, v.s_ecolo, v.s_ident
from prog
cross join (values
  ('<position 1>', '<theme 1>', '[{"terme":"<mot>","definition":"<définition ≤ 200 car.>"}]', 1::smallint,  null::smallint, null::smallint, null::smallint, null::smallint),
  ('<position 2>', '<theme 2>', '[]', null::smallint, -1::smallint, null::smallint, null::smallint, null::smallint)
) as v("position", theme, termes, s_eco, s_soc, s_aut, s_ecolo, s_ident)
returning id;
```

Contrôle ensuite, et bilan en mots simples (parti, programme, nombre de propositions
écrites, sources lues) :

```sql
select pa.nom, pr.echeance, pr.date_programme, count(p.id) as nb_propositions
from opinions_partis pa
join opinions_programmes pr on pr.parti_id = pa.id
left join opinions_propositions p on p.programme_id = pr.id
where lower(pa.nom) = lower('<nom>')
group by pa.nom, pr.id, pr.echeance, pr.date_programme
order by pr.created_at desc;
```

Le nombre doit égaler le nombre de lignes validées. Rappeler : l'app met ses données
en cache, **tirer pour rafraîchir sur l'onglet Partis**.

Si l'utilisateur veut importer plusieurs partis, répéter le processus complet **parti
par parti**, avec la même grille, puis faire le contrôle de cohérence par thème
(section 2, règle 5) avant d'écrire quoi que ce soit.

## 5. Corriger / compléter un programme existant

Lire d'abord ce qui est en base :

```sql
select p.id, p.theme, p."position", p.termes,
       p.score_economique, p.score_societal, p.score_autorite, p.score_ecologie, p.score_identite
from opinions_propositions p
where p.programme_id = '<programme_id>'
order by p.theme, p.created_at;
```

Proposer les changements, puis appliquer **après accord** :

```sql
-- Modifier une proposition (réécriture, thème ou scores)
update opinions_propositions set
  "position" = '<position ≤ 280 car.>',
  theme = '<theme>',
  termes = '<[{"terme":"…","definition":"…"}] ou []>'::jsonb,
  score_economique = <..|null>, score_societal = <..|null>, score_autorite = <..|null>,
  score_ecologie = <..|null>, score_identite = <..|null>,
  updated_at = now()
where id = '<proposition_id>'
returning id, "position", theme;

-- Ajouter des propositions à un programme existant (enrichir)
insert into opinions_propositions
  (programme_id, "position", theme, termes,
   score_economique, score_societal, score_autorite, score_ecologie, score_identite)
values
  ('<programme_id>', '<position>', '<theme>', '[]'::jsonb, 1::smallint, null::smallint, null::smallint, null::smallint, null::smallint)
returning id;

-- Supprimer une proposition (après accord explicite)
delete from opinions_propositions where id = '<proposition_id>' returning id;
```

Toute proposition modifiée ou ajoutée suit la section 3 (langage simple, mots-clés et
définitions dans `termes`, 280 caractères) et la grille de la section 2. Avant de supprimer ou de réécrire
fortement une proposition, vérifier si l'utilisateur l'a déjà « reprise » :
`select id, "position" from opinions_idees where proposition_id = '<id>'` et l'en
avertir.

## 6. Comparer des partis

Déclencheurs : « compare X et Y sur la santé », « qui propose quoi sur l'immigration ».

Résoudre les partis (lecture seule), puis lire les propositions du **programme le plus
récent** de chacun (`date_programme` la plus récente, sinon le dernier créé) :

```sql
select id, nom, sigle from opinions_partis
where lower(nom) like lower('%<x>%') or lower(sigle) = lower('<x>');

with dernier as (
  select distinct on (parti_id) id, parti_id, echeance, date_programme
  from opinions_programmes
  order by parti_id, date_programme desc nulls last, created_at desc
)
select pa.nom, pa.sigle, d.echeance, d.date_programme, p.theme, p."position",
       p.score_economique, p.score_societal, p.score_autorite, p.score_ecologie, p.score_identite
from dernier d
join opinions_partis pa on pa.id = d.parti_id
join opinions_propositions p on p.programme_id = d.id
where pa.id in ('<id X>', '<id Y>')      -- ou retirer cette ligne pour « tous les partis »
  and p.theme = '<theme>'                -- ou retirer pour tous les thèmes
order by p.theme, pa.nom, p.created_at;
```

Présenter **thème par thème, côte à côte**, sans prendre parti, en mots simples (mots
techniques définis). Dire de quel programme (échéance, date) viennent les propositions
de chaque parti, et signaler quand un parti n'a rien sur un thème (ce n'est pas un
jugement : « rien dans le programme lu »). Signaler les affirmations factuelles
contestées ou à vérifier. Aucun ton moqueur ou admiratif.

## 7. Qui me ressemble (proximité)

Calcul « comme l'app » :
- **Mes positions** : idées `validee` avec thème, par couple (thème, axe), moyenne
  pondérée par la conviction (`hesitant` 0,5 · `plutot` 1 · `certain` 1,5).
- **Un parti** : propositions de son programme le plus récent, moyenne simple par
  couple (thème, axe).
- On ne compare que les couples où **les deux** ont une position.
- Ressemblance d'un couple = `1 − |écart| / 4`.
- Poids du thème d'après `opinions_priorites` : secondaire 0,5 · normal 1 (aussi
  quand le thème n'a pas de ligne) · prioritaire 2.
- Proximité = somme pondérée des ressemblances / somme des poids, en %.
- **Couverture** : « comparé sur N de tes M positions » (N = couples comparés pour ce
  parti, M = tous tes couples).

```sql
with mes as (
  select i.theme, x.axe, sum(x.score * i.poids) / sum(i.poids) as val
  from (
    select theme, score_economique, score_societal, score_autorite, score_ecologie, score_identite,
           case conviction when 'hesitant' then 0.5 when 'plutot' then 1.0 when 'certain' then 1.5 end as poids
    from opinions_idees
    where statut = 'validee' and theme is not null
  ) i
  cross join lateral (values
    ('economique', i.score_economique), ('societal', i.score_societal),
    ('autorite', i.score_autorite), ('ecologie', i.score_ecologie),
    ('identite', i.score_identite)) as x(axe, score)
  where x.score is not null
  group by i.theme, x.axe
), dernier as (
  select distinct on (parti_id) id, parti_id
  from opinions_programmes
  order by parti_id, date_programme desc nulls last, created_at desc
), eux as (
  select d.parti_id, p.theme, x.axe, avg(x.score) as val
  from dernier d
  join opinions_propositions p on p.programme_id = d.id
  cross join lateral (values
    ('economique', p.score_economique), ('societal', p.score_societal),
    ('autorite', p.score_autorite), ('ecologie', p.score_ecologie),
    ('identite', p.score_identite)) as x(axe, score)
  where x.score is not null
  group by d.parti_id, p.theme, x.axe
), couples as (
  select e.parti_id, m.theme, m.axe,
         1 - abs(m.val - e.val) / 4.0 as similarite,
         case coalesce(pr.niveau, 'normal')
           when 'secondaire' then 0.5 when 'prioritaire' then 2.0 else 1.0 end as poids
  from mes m
  join eux e on e.theme = m.theme and e.axe = m.axe
  left join opinions_priorites pr on pr.theme = m.theme
)
select pa.nom, pa.sigle,
       round(100 * sum(c.poids * c.similarite) / nullif(sum(c.poids), 0)) as proximite_pct,
       count(c.axe)                as positions_comparees,
       (select count(*) from mes)  as mes_positions
from opinions_partis pa
left join couples c on c.parti_id = pa.id
group by pa.id, pa.nom, pa.sigle
order by proximite_pct desc nulls last, pa.nom;
```

Pour voir le détail d'un parti (quels sujets rapprochent ou éloignent), remplacer le
`select` final par :

```sql
select c.theme, c.axe, round(100 * c.similarite) as ressemblance_pct, c.poids
from couples c where c.parti_id = '<parti_id>' order by c.theme, c.axe;
```

Restitution (en mots simples) : le pourcentage de chaque parti, la couverture, ce qui
rapproche et ce qui éloigne le plus (sujet par sujet), et le rappel que **ce n'est pas
un conseil de vote**. Si l'utilisateur n'a aucune idée validée, ou si un parti n'a
aucun couple en commun, le dire au lieu d'afficher un chiffre. Explication type :

> On regarde, sujet par sujet, si toi et le parti pensez la même chose. Plus vous
> pensez pareil, plus le pourcentage est grand. On ne compte que les sujets où vous
> avez tous les deux un avis. Ce n'est pas un conseil de vote.

## 8. Priorités par thème

Expliquer d'abord simplement : « plus un sujet compte pour toi, plus il pèse dans la
comparaison ». Un thème sans ligne vaut « normal ».

```sql
-- Lire (les 12 thèmes, avec la valeur « normal » par défaut)
select t.theme, coalesce(pr.niveau, 'normal') as niveau
from unnest(array['economie','fiscalite','travail','sante','education','immigration',
                  'ecologie','securite','institutions','international','culture','numerique'])
     as t(theme)
left join opinions_priorites pr on pr.theme = t.theme
order by t.theme;

-- Modifier à la demande (niveau : secondaire | normal | prioritaire)
insert into opinions_priorites (theme, niveau, updated_at)
values ('<theme>', '<niveau>', now())
on conflict (theme) do update set niveau = excluded.niveau, updated_at = now()
returning theme, niveau;
```

Vérifier que `theme` est dans la liste des 12 slugs (la base ne le vérifie pas) et
`niveau` dans les trois valeurs avant d'écrire.

## 9. Reprendre une proposition dans mes idées

Quand une proposition inspire l'utilisateur, la lui signaler et proposer de la
reprendre, **mais le laisser le faire dans l'app** (bouton « Reprendre dans mes
idées ») : c'est l'app qui renseigne `opinions_idees.proposition_id`. Ne jamais
remplir ce champ à sa place, ne jamais créer d'idée à partir d'une proposition de
parti de sa propre initiative, et ne jamais modifier ses idées ni leur statut dans les
comportements « partis », sauf demande explicite.

## 10. Suppressions

La suppression est **en cascade** : supprimer un parti supprime ses programmes et leurs
propositions ; supprimer un programme supprime ses propositions. Ne jamais supprimer
sans accord explicite, et **toujours annoncer d'abord combien de lignes disparaîtront** :

```sql
select pa.nom,
       count(distinct pr.id) as nb_programmes,
       count(p.id)           as nb_propositions,
       count(i.id)           as idees_reprises_concernees
from opinions_partis pa
left join opinions_programmes pr on pr.parti_id = pa.id
left join opinions_propositions p on p.programme_id = pr.id
left join opinions_idees i on i.proposition_id = p.id
where pa.id = '<parti_id>'
group by pa.id, pa.nom;
-- puis, après accord explicite :
-- delete from opinions_programmes where id = '<programme_id>';
-- delete from opinions_partis where id = '<parti_id>';
```

Les idées de l'utilisateur ne sont **pas** supprimées : la clé `proposition_id` est en
`on delete set null`, elles perdent seulement le lien avec la proposition. Le lui dire
si `idees_reprises_concernees` n'est pas zéro.
