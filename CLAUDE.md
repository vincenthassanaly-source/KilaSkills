## Workflow Git

À la fin de chaque session de modifications (une fois les changements terminés et vérifiés), fusionne toi-même la pull request vers `kilaskillsmain` (la branche par défaut de ce dépôt, par exemple avec `gh pr merge --squash --delete-branch`), sans attendre de confirmation supplémentaire. L'objectif est que le travail soit visible en ligne et déployé immédiatement à la fin de la session, sans étape manuelle de ma part. Si des vérifications (build, tests, lint) sont disponibles, assure-toi qu'elles passent avant de fusionner.

## Notification push systématique

À la fin de **chaque** réponse, dès que c'est à moi de répondre (travail terminé, question posée, blocage, simple réponse à une question…), envoie-moi une notification push (outil `PushNotification`) en une phrase courte résumant ce qui a été fait ou ce que tu attends de moi — je ne suis pas toujours en train de regarder la session, et je ne veux pas avoir à ouvrir l'app pour savoir si c'est à moi de jouer. Envoie-la en dernier, après la fusion de la pull request le cas échéant.

## Versionnement du plugin kilaskills

Claude Code met en cache le plugin `kilaskills` par numéro de version : sans changement de `version`, `claude plugin update` ne récupère rien et les nouvelles sessions n'ont pas les skills ajoutés.

À chaque ajout, suppression ou modification de skill dans `plugin/skills/`, incrémente `version` dans `plugin/.claude-plugin/plugin.json` dans la même pull request (mineure pour un nouveau skill, patch pour une modification). Ne fusionne jamais une PR qui touche `plugin/skills/` sans ce bump.
