---
name: reveil-cycles-sommeil
description: "Proposer des heures de réveil calées sur la fin d'un cycle de sommeil, à partir de l'heure actuelle (ou d'une heure de coucher donnée). Utiliser quand l'utilisateur demande à quelle heure mettre son réveil, à quelle heure se coucher, ou à quelle heure il doit se réveiller demain matin (ex: \"à quelle heure je dois mettre mon réveil\", \"à quelle heure je dois me réveiller demain\", \"je me couche maintenant, quand me réveiller ?\")."
metadata:
  origin: kilaskills
---

# Réveil en fin de cycle de sommeil

Propose plusieurs heures de réveil possibles, chacune calée sur la fin d'un cycle
de sommeil complet, pour réduire les chances de se réveiller en plein sommeil
profond (grogginess / inertie du sommeil).

## Hypothèses du modèle

- Durée d'un cycle de sommeil : **90 minutes** (valeur standard communément admise).
- Délai d'endormissement : **15 minutes** par défaut (temps entre le coucher /
  "maintenant" et l'entrée effective en sommeil). Si l'utilisateur précise qu'il
  s'endort plus vite ou plus lentement, utiliser sa valeur à la place.
- Nombre de cycles à proposer : **5 et 6 cycles** par défaut (7h30 et 9h de sommeil),
  en ajoutant **4 cycles** (6h) si l'heure actuelle est déjà tardive (l'utilisateur
  se couche après 1h du matin) pour laisser une option de nuit courte.

## Déroulé

1. **Déterminer l'heure de référence** : par défaut l'heure actuelle (heure locale
   de l'utilisateur, à demander/déduire si ambiguë). Si l'utilisateur donne une
   heure de coucher explicite ("je me couche à 23h"), utiliser celle-ci à la place.
2. **Calculer l'heure d'endormissement estimée** = heure de référence + délai
   d'endormissement (15 min par défaut).
3. **Calculer les heures de réveil** = heure d'endormissement + (N × 90 min), pour
   N = 4, 5, 6 (et éventuellement 7 si le coucher a lieu tôt, avant 22h, pour laisser
   une option de nuit longue).
4. **Présenter 3 à 4 propositions**, avec pour chacune :
   - l'heure de réveil,
   - le nombre de cycles et la durée de sommeil totale correspondante,
   - une heure au format lisible (ex: "5h15" plutôt que "05:15").

   Mettre en avant (par exemple en premier ou en gras) l'option à 5 ou 6 cycles
   comme le meilleur compromis, sauf si le contexte donné par l'utilisateur
   (heure tardive, contrainte du lendemain) suggère une autre option.
5. Si l'utilisateur précise une contrainte de réveil (ex: "je dois être debout
   avant 7h"), ne proposer que les options compatibles, et signaler si aucune
   option à cycle complet ne convient (proposer alors la plus proche en dessous
   de la contrainte).
6. Ne pas insister sur les hypothèses (délai d'endormissement, durée de cycle) dans
   la réponse sauf si elles sont pertinentes ou si l'utilisateur les remet en
   question — rester concis, format liste courte.

## Exemple

Utilisateur (il est 23h42) : "à quelle heure je dois mettre mon réveil ?"

Réponse type :

> En te couchant maintenant (endormissement ~23h57), pour finir un cycle complet :
> - 4 cycles → **5h27** (6h de sommeil)
> - 5 cycles → **6h57** (7h30 de sommeil) — bon compromis
> - 6 cycles → **8h27** (9h de sommeil)

## Garde-fous

- Ne jamais confondre l'heure actuelle et l'heure d'endormissement : toujours
  ajouter le délai d'endormissement avant de calculer les cycles.
- Si l'utilisateur ne précise rien, ne pas demander de confirmation supplémentaire
  pour le délai d'endormissement ou la durée de cycle : utiliser les valeurs par
  défaut et les proposer directement.
- Ce skill ne modifie aucune donnée, ne crée pas d'événement de calendrier ni de
  rappel : il se contente de proposer des heures en réponse dans le chat, sauf si
  l'utilisateur demande explicitement de créer un rappel (auquel cas utiliser
  l'outil ou le skill approprié, ex: calendrier ou Kilio).
