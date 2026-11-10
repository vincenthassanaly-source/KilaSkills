---
name: kilio-parcours-utilisateur
description: "Utiliser l'app Kilio comme un vrai utilisateur ET voir les captures d'écran de chaque action : Claude écrit des parcours (créer, éditer, cocher, archiver, rechercher…) à partir du code d'un module, les rejoue dans un navigateur, capture l'écran après CHAQUE étape, relève erreurs console, requêtes en échec, débordements et écritures en base, puis produit une pellicule HTML et un rapport de problèmes. Utiliser quand l'utilisateur dit « teste le module X comme un utilisateur », « utilise l'app et montre-moi les écrans », « trouve les bugs d'usage de X », ou veut enchaîner usage réel + captures + critique impeccable."
metadata:
  origin: kilio
---

# Parcours utilisateur Kilio (usage réel + captures)

Rejoue des parcours dans l'app et photographie l'écran après chaque action : on voit
l'état de l'interface *en fonction de l'usage*, pas seulement les pages au repos.
Complète `kilio-ecrans-module` (écrans au repos). Aucune écriture en base réelle.

## Préparer l'environnement

Lancer l'app contre le faux Supabase, jamais la base réelle : `e2e/run-instant-rig.sh`
(port 3100, faux Supabase sur 54321, voir `instant-nav.rig.md`). Passer `--mock
http://localhost:54321` au script pour relever les écritures (`/__writes`) et `--reset`
pour repartir d'une base propre à chaque parcours (`/__reset`). Le verrou biométrique du
journal est désactivé par `E2E_VERROU_DESACTIVE=1` (déjà posé par le rig).

## Étapes

1. **Comprendre le module** : lire `src/app/(app)/<module>/`, ses composants et actions
   serveur, et les rapports `reports/*<module>*` (choix déjà tranchés).
2. **Écrire les parcours** en JSON dans `reports/parcours/<module>/scenarios/` (un fichier
   par parcours, 5 à 15 étapes). Couvrir :
   - le chemin nominal (créer, modifier, terminer, supprimer/archiver) ;
   - la persistance (`reload`, puis `expect_text` : la donnée est-elle toujours là ?) ;
   - les cas limites : champ vide, texte très long, double clic, retour arrière, liste vide ;
   - mobile **et** desktop (deux fichiers ou deux variantes), clair et sombre au besoin.
   Format : voir l'en-tête de `scripts/parcours.mjs`. Les cibles sont des sélecteurs
   Playwright, de préférence par rôle accessible (`role=button[name=/ajouter/i]`) : si
   une cible est introuvable pour un utilisateur, c'est déjà un problème d'accessibilité
   à signaler.
3. **Lancer** (depuis la racine de Kilio) :

   ```bash
   node "${CLAUDE_SKILL_DIR}/scripts/parcours.mjs" reports/parcours/<module>/scenarios \
     --base http://localhost:3100 --mock http://localhost:54321 --reset \
     --out reports/parcours/<module>
   ```

   Sortie : un PNG par étape, `parcours.json` (statut, anomalies, écritures, durée) et
   `index.html` (pellicule : une vignette par étape, bordure verte/orange/rouge).
4. **Regarder les captures** (Read sur les PNG des étapes en anomalie ou en échec, et au
   moins la dernière de chaque parcours) : le script détecte erreurs et débordements, pas
   un libellé ambigu, un bouton trop petit ou un état de chargement qui reste.
5. **Rapporter**, classé par gravité : étape, capture, ce qui s'est passé, ce qui était
   attendu, cause probable dans le code, correction proposée. Distinguer un vrai bug d'un
   artefact du faux Supabase (donnée absente du mock) ; ne rien inventer.
6. **Ne corriger qu'après accord.** Pour un bug confirmé, proposer d'en faire un test
   Playwright dans `e2e/` (non-régression).

## Limites à dire à l'utilisateur

- Le faux Supabase n'est pas la base réelle : un bug dû à de vraies données ou à une règle
  serveur peut échapper.
- Pas de caméra (scanner), de notifications ni de gestes tactiles fins.
- Le ressenti (« pénible à utiliser ») reste un jugement : le signaler comme tel.

## Enchaîner avec les autres skills

Ordre conseillé pour un module : `kilio-ecrans-module` (écrans au repos) →
`kilio-parcours-utilisateur` (usage réel) → `/impeccable critique` en lui donnant les
deux planches et la liste des problèmes d'usage comme matière.
