# Exemple de session : expliquer les propositions d'un parti

Exemple **fictif** : « Parti Exemple », ses mesures et ses explications n'existent pas.
Il montre la forme d'un tableau de validation **pour un thème**, avec le niveau de
langage, la symétrie entre « pour » et « contre » et la longueur attendue (viser 250 à
450 caractères par champ, 600 au plus). Ici, les trois propositions viennent de thèmes
différents pour montrer plusieurs cas dans un seul fichier ; en vrai, la relecture se
fait **un thème à la fois**. Rien de ceci ne doit être écrit en base.

---

> **Moi** : génère les explications du programme du Parti Exemple.

**1. Ce qui reste à expliquer (lecture seule, rien n'est écrit)**

> **Claude** : J'ai lu le programme officiel « Présidentielle 2027 » du Parti Exemple
> (le PDF publié sur son site). Il y a 28 propositions sans explication : 5 en
> fiscalité, 4 en santé, 3 en éducation… Je commence par la fiscalité. Si l'une d'elles a
> déjà une explication, je ne la touche pas sans te le dire.

**2. Tableau de validation (un thème)**

> Chaque case est un texte court, en mots simples, sans avis. « Pour » et « contre »
> ont le même poids. Le chiffre entre parenthèses est le nombre de caractères (600 au
> plus). La source est le texte du programme officiel du parti, qui fait foi.
>
> | N° | Proposition | Ce que ça change | Le meilleur argument pour | Le meilleur argument contre |
> |---|---|---|---|---|
> | 1 (fiscalité) | Supprimer la TVA sur les produits de base. | La TVA est une taxe déjà comprise dans le prix. Aujourd'hui, un paquet de pâtes à 2 € contient une petite part de TVA qui va à l'État. Avec cette mesure, cette part disparaît pour les produits de base, comme les pâtes, le riz ou le lait. Le prix en magasin peut baisser, si les magasins répercutent la baisse. *(309)* | Les familles qui ont peu d'argent dépensent une grande part de leur budget pour manger. Un prix plus bas sur les produits de base les aide tout de suite, sans formulaire à remplir. Ce sont des achats que personne ne peut éviter, donc la baisse touche tout le monde de la même façon. *(282)* | L'État reçoit moins d'argent : il doit trouver ailleurs de quoi payer les écoles ou les hôpitaux, ou emprunter. Les études ne sont pas d'accord sur le fait que les magasins baissent vraiment leurs prix. La baisse profite aussi aux personnes qui ont beaucoup d'argent. *(267)* |
> | 2 (santé) | Rembourser les lunettes et les soins des dents en totalité. | Aujourd'hui, la Sécurité sociale (l'organisme public qui rembourse une partie des soins) paie seulement une partie d'une paire de lunettes ou d'un soin chez le dentiste. Le reste est payé par la personne, ou par sa mutuelle (une assurance privée pour la santé). Avec cette mesure, la personne ne paierait plus rien pour ces soins. *(330)* | Certaines personnes retardent des soins des dents ou des yeux parce qu'elles n'ont pas les moyens d'avancer l'argent. Un soin repoussé peut devenir plus grave et plus cher plus tard. Quand tout est remboursé, chacun se soigne quand il en a besoin, quels que soient ses revenus ou sa mutuelle. *(292)* | Cela coûte cher à la Sécurité sociale, donc aux cotisations (l'argent pris sur les salaires pour payer la santé) ou aux impôts. Si tout est gratuit, on pourrait demander plus de soins que nécessaire : les spécialistes ne sont pas d'accord sur ce risque. Le choix dépend de ce qui compte le plus pour l'argent public. *(316)* |
> | 3 (éducation) | Avoir au plus 20 élèves par classe à l'école primaire. | Aujourd'hui, une classe de primaire (de 6 à 11 ans) peut compter plus de 20 élèves. Avec cette mesure, il y aurait au plus 20 élèves par classe. Pour cela, il faudrait plus de classes, donc plus de maîtres et de maîtresses et plus de salles. Chaque enfant a un adulte un peu plus disponible pour lui. *(300)* | Avec moins d'élèves, le maître ou la maîtresse peut aider chaque enfant plus longtemps. Les enfants qui ont du mal à lire ou à compter sont repérés plus vite. Dans une classe plus petite, il y a aussi moins de temps perdu à faire la discipline, et plus de temps pour apprendre. *(277)* | Il faut recruter et payer beaucoup de maîtres et de maîtresses, et construire des salles : cela coûte cher et prend des années. Les études ne sont pas d'accord sur l'effet de la taille de la classe, qui dépend aussi de la façon d'enseigner. Certains préfèrent mettre cet argent ailleurs, comme dans les salaires ou la formation. *(328)* |
>
> Ce que j'ai fait attention à respecter :
> - même longueur à peu près pour « pour » et « contre », et même niveau de détail ;
> - les mots difficiles sont expliqués dans la phrase (TVA, Sécurité sociale, mutuelle,
>   cotisations) ;
> - quand les spécialistes ne sont pas d'accord sur un fait, je le dis dans la phrase
>   (« les études ne sont pas d'accord ») ; quand c'est un choix de valeurs, je le dis
>   aussi (« le choix dépend de ce qui compte le plus ») ;
> - je me suis appuyé sur le texte de chaque proposition, pas sur ce qu'on sait du parti ;
> - aucune phrase ne te dit quoi voter.
>
> Quelles lignes veux-tu corriger ? Si tout te va, dis « ok » et j'écris ce thème d'un
> coup, puis je te montre le suivant.

**3. Correction et accord**

> **Moi** : pour la 2, ajoute que ça concerne aussi les prothèses. Le reste est bon.
>
> **Claude** : Je l'ajoute dans « ce que ça change », puis je recompte les caractères : c'est sous la limite de 600. J'écris
> les explications de ce thème ?
>
> **Moi** : oui.

**4. Écriture d'un lot, puis thème suivant (`partis.md`, section 11)**

> **Claude** : C'est écrit, et j'ai vérifié : 5 propositions de fiscalité expliquées sur 5.
> Source lue : le PDF officiel du programme, sur le site du parti. Pense à tirer vers le
> bas pour rafraîchir, sur l'onglet Partis. On passe à la santé ?

**5. Si une explication existe déjà**

> **Claude** : La proposition 3 a déjà une explication. Voici l'ancienne et la nouvelle,
> côte à côte. Je ne remplace rien sans ton accord : laquelle gardes-tu ?
