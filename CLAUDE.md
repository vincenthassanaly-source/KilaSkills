# Consignes pour Claude Code sur ce dépôt (KilaSkills)

## Branche par défaut

La branche par défaut de ce dépôt est `main`. Toute PR doit être ouverte contre `main`.

## Workflow automatique : PR + merge à chaque modification

Objectif : que les modifications faites sur ce dépôt soient visibles en ligne (sur `main`)
sans intervention manuelle de l'utilisateur.

À chaque fois qu'une tâche demandée par l'utilisateur aboutit à une modification de ce
dépôt (fichiers de skills, plugin, config, etc.) :

1. Travailler sur une branche dédiée (jamais commit directement sur `main`).
2. Committer avec un message clair, pousser la branche.
3. Ouvrir une pull request de cette branche vers `main`. Ceci vaut comme demande
   explicite de l'utilisateur de créer une PR — l'autorisation d'avance couvre tout
   le dépôt, pas besoin de redemander à chaque fois.
4. Avant de fusionner :
   - S'il existe des checks CI configurés sur la PR, attendre leur résultat.
     - Si tous les checks passent (ou si aucun check n'est configuré), fusionner
       automatiquement la PR dans `main` (merge standard).
     - Si un check échoue, NE PAS fusionner. Laisser la PR ouverte, expliquer
       clairement dans un commentaire ce qui bloque, et prévenir l'utilisateur.
   - S'il y a un conflit de fusion avec `main`, NE PAS fusionner. Résoudre le
     conflit si c'est trivial et sûr, sinon demander à l'utilisateur.
5. Ne jamais utiliser cette autorisation pour forcer un merge en cas d'échec CI,
   de conflit non résolu, ou de doute sur la sécurité/correction du changement :
   dans ces cas, s'arrêter et signaler le blocage plutôt que de fusionner quand même.

## Notification à la fin du travail

Une fois la tâche terminée ET la PR effectivement fusionnée dans `main`, envoyer une
notification push à l'utilisateur (outil `PushNotification`) résumant en une phrase
ce qui a été fait et confirmant la fusion dans `main`.

Si la PR n'a pas pu être fusionnée (CI rouge, conflit, blocage quelconque), ne pas
envoyer de notification de succès : signaler le blocage à la place.
