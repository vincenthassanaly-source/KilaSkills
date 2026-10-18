# Axes, échelle de score et charte de neutralité

Lecture avant de classer ou de challenger. Les libellés d'axe sont des **conventions
d'affichage** : un score sert à situer une idée sur une échelle, pas à la juger.

## Échelle commune (tous les axes)

| Score | Sens |
|---|---|
| `-2` | position très marquée vers le pôle « -2 » de l'axe |
| `-1` | penche vers ce pôle, avec des réserves ou des garde-fous |
| `0` | **neutralité assumée** : l'idée tient explicitement un équilibre entre les deux pôles |
| `+1` | penche vers le pôle « +2 », avec des réserves ou des garde-fous |
| `+2` | position très marquée vers le pôle « +2 » de l'axe |
| `null` | l'axe n'est **pas concerné** par l'idée (par défaut) |

`0` ≠ `null`. Mettre `0` signifie « cette idée concerne l'axe et se place au milieu ».
En cas de doute entre `0` et `null`, choisir `null`, ou poser la question.

## Axes

### `score_economique` — État (-2) ↔ Marché (+2)
Qui doit décider et financer : la puissance publique (régulation, services publics,
redistribution, propriété publique) ou les mécanismes de marché (concurrence,
initiative privée, fiscalité plus légère).
- Concerné : fiscalité, dépenses publiques, régulation du travail, services publics,
  privatisations, aides sociales.
- Rarement concerné : mesures de pure procédure, symboles, questions de mœurs.

### `score_societal` — progressiste (-2) ↔ conservateur (+2)
Rapport aux évolutions des normes sociales et des mœurs (famille, fin de vie,
croyances, éducation aux valeurs) : accompagner le changement ou préserver l'existant.
- Concerné : bioéthique, famille, laïcité dans ses applications, éducation aux valeurs.
- Éviter d'y ranger une idée qui relève d'un autre axe (une mesure de sécurité n'est
  pas « conservatrice » par nature : voir l'axe autorité).

### `score_autorite` — libertés (-2) ↔ autorité (+2)
Arbitrage entre libertés individuelles et pouvoir de contrainte de l'État (police,
justice, surveillance, sanctions, contrôle).
- Concerné : sécurité, justice pénale, surveillance numérique, libertés publiques.

### `score_ecologie` — écologie (-2) ↔ productivisme (+2)
Priorité donnée à la limitation des atteintes à l'environnement ou à la production et
à la croissance quand les deux entrent en tension.
- Concerné : énergie, transports, agriculture, aménagement, normes environnementales.

### `score_identite` — ouverture (-2) ↔ souveraineté (+2)
Rapport à l'ouverture (frontières, échanges, intégration européenne et internationale,
diversité) ou à la souveraineté nationale et à la préservation d'une identité commune.
- Concerné : immigration, Europe, commerce international, souveraineté industrielle.

## Thèmes (liste fermée)

`economie, fiscalite, travail, sante, education, immigration, ecologie, securite,
institutions, international, culture, numerique`

Un seul thème par idée. Si l'idée en touche deux, retenir celui du **levier principal**
(l'action proposée), pas celui de la motivation, et le mentionner à l'utilisateur.

## Classement discuté

Écrire « classement discuté » quand :
- une même mesure change de pôle selon l'angle (ex. impôt : « justice fiscale » ou
  « poids de l'État » ?) ;
- les traditions politiques en font des lectures opposées ;
- l'idée mélange deux objets (la scinder en deux positions est alors à proposer).

Donner la raison en une ligne et laisser l'utilisateur trancher.

## Charte de neutralité

1. **Steelman, jamais strawman** : tout argument, pour ou contre, est présenté tel que
   le défendrait un partisan informé et de bonne foi.
2. **Pas d'avis partisan** : pas de « on devrait », pas d'adjectifs de valeur sur les
   idées ou les camps. Les questions valent mieux que les conclusions.
3. **Faits vs valeurs** : séparer « ce que disent les données (parfois contestées) » de
   « ce qu'on choisit de privilégier ». Signaler explicitement les faits contestés ou à
   vérifier, et les chiffres dont l'ordre de grandeur ou la source doivent être
   contrôlés avant d'être cités comme acquis.
4. **Symétrie** : appliquer le même niveau d'exigence à une idée de n'importe quel bord.
   Se demander : « ferais-je la même remarque si l'idée venait du camp opposé ? »
5. **Vocabulaire** : préférer les libellés des axes ; ne pas utiliser « gauche » ou
   « droite » comme verdict. Éviter les termes chargés ; en cas de termes concurrents
   pour un même objet, nommer les deux ou en choisir un descriptif.
6. **Sujets sensibles** (immigration, fin de vie, laïcité, sécurité…) : rester
   factuel, rappeler le cadre légal ou les données connues, et ne jamais présupposer
   les intentions de ceux qui défendent un point de vue.
7. **Incertitude assumée** : dire « je ne sais pas / c'est disputé » plutôt que de
   trancher. L'utilisateur reste l'auteur de ses opinions.
