# Exemple de session : importer le programme d'un parti

Exemple **fictif** : « Parti Exemple » et ses mesures n'existent pas. Il montre la forme
des échanges, de la recherche à l'écriture, avec un tableau de validation en langage
simple. Rien de ceci ne doit être écrit en base ; pour un vrai import, tout vient du
programme officiel lu pendant la session.

---

> **Moi** : importe le programme du Parti Exemple pour la présidentielle 2027.

**1. Vérification en base (rien n'est écrit)**

> **Claude** : Je regarde d'abord si ce parti est déjà dans Kilio… Non, il n'y est pas
> encore. Je cherche son programme officiel.

**2. Recherche et lecture (en mots simples)**

> **Claude** : Voilà ce que j'ai fait.
> - J'ai cherché le site officiel du parti, et j'ai vérifié que c'est le bon : le site
>   principal du parti renvoie vers lui, et des sites d'information le citent aussi.
> - J'ai trouvé le PDF du programme « Présidentielle 2027 », publié le 1er septembre
>   2026. Je n'ai pas trouvé de version plus récente.
> - Je l'ai lu en entier, chapitre par chapitre (outil de recherche, puis lecture du
>   PDF page par page).
> - Le programme annonce 40 mesures. J'en ai retenu 28 qui sont assez précises pour
>   être classées. Les autres sont des souhaits généraux, sans mesure concrète.
>
> Rien n'est enregistré dans Kilio pour l'instant, et je ne garde aucun lien en base.

**3. Tableau de validation (en mots simples)**

> Les scores vont de -2 à +2 (« — » = le sujet ne concerne pas cet axe). Sur l'axe
> **économique**, -2 veut dire « l'État s'occupe de plus de choses » et +2 « les
> entreprises et les gens s'en occupent plus ». Sur l'axe **autorité**, -2 veut dire
> « plus de libertés pour chacun » et +2 « plus de règles et de contrôles imposés par
> l'État ».
>
> | N° | Thème | Ce qui sera écrit dans Kilio | Ce que dit le programme (version courte) | Éco | Aut | À vérifier |
> |---|---|---|---|---|---|---|
> | 1 | fiscalite | Supprimer la TVA (une taxe déjà comprise dans le prix de ce qu'on achète) sur les produits de première nécessité. | « Taux zéro de TVA sur l'alimentation de base. » | -1 | — | Quels produits sont « de première nécessité » ? Le texte ne le précise pas. |
> | 2 | travail | Augmenter de 10 % le SMIC (la somme la plus basse qu'un employeur a le droit de payer pour une heure de travail). | « Revalorisation du SMIC de 10 %. » | -1 | — | — |
> | 3 | securite | Créer des peines planchers (une punition minimale fixée par la loi, en dessous de laquelle le juge ne peut pas aller) pour les violences graves. | « Instauration de peines minimales pour les violences aggravées. » | — | 2 | Je n'ai mis que l'axe autorité, car le texte ne parle pas d'argent public. |
> | 4 | travail | Payer une aide aux entreprises qui prennent des apprentis (des jeunes qui se forment en travaillant dans une entreprise). | « Prime de l'État pour toute embauche d'un apprenti. » | -1 | — | Classement discuté : c'est l'État qui paie (je note -1), mais l'aide va à des entreprises. À toi de trancher. |
>
> *(… 24 autres lignes dans le même format …)*
>
> **Ce qui vient du programme** : la colonne « Ce que dit le programme ». **Ce qui est
> mon interprétation** : les scores. Je les ai mis seulement d'après le texte du
> programme, pas d'après ce que je sais du parti.
>
> **Les mots que j'ai expliqués** (dis-moi si une définition ne te va pas) :
> - TVA : une taxe déjà comprise dans le prix de ce qu'on achète ;
> - SMIC : la somme la plus basse qu'un employeur a le droit de payer pour une heure
>   de travail ;
> - peines planchers : une punition minimale fixée par la loi, en dessous de laquelle le
>   juge ne peut pas aller ;
> - apprenti : un jeune qui se forme en travaillant dans une entreprise.
>
> Ces quatre mots ne sont pas tous dans le lexique de départ : « apprenti » est
> nouveau. Veux-tu que je te propose de l'ajouter plus tard au lexique du skill ?
>
> Quelles lignes veux-tu retirer ou corriger ? Si tout te va, dis « ok » et j'écris
> tout d'un coup.

**4. Corrections et accord**

> **Moi** : pour la 4, garde -1. Et pour la 1, mets plutôt « produits de base ».
>
> **Claude** : C'est fait, 28 propositions restent, avec ces deux changements. J'ai vérifié que chaque phrase tient
> en 280 caractères avec ses explications (la plus longue en fait 241). Je les écris ?
>
> **Moi** : oui.

**5. Écriture en un seul lot (le gabarit SQL de `partis.md`, section 4, étape e)**

> **Claude** : C'est écrit, et j'ai vérifié.
> - Parti : Parti Exemple (nouveau).
> - Programme : « Présidentielle 2027 », daté du 1er septembre 2026.
> - Propositions écrites : 28 sur 28.
> - Source lue : le PDF officiel du programme, trouvé sur le site du parti.
>
> L'application garde tes données un moment en mémoire : tire vers le bas pour
> rafraîchir, sur l'onglet Partis. Je peux aussi te montrer la proximité entre toi et
> ce parti, si tu veux.
