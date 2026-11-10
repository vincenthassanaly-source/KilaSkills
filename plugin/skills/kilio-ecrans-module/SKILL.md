---
name: kilio-ecrans-module
description: "Montrer TOUS les écrans d'un module Kilio (pharmacie, nutrition, taches, musculation…) : énumère les routes du module depuis src/app/(app)/<module>/, résout les routes dynamiques ([id]) avec de vraies pages, capture chaque écran (mobile + desktop, clair + sombre) et produit une planche contact HTML. Utiliser quand l'utilisateur dit « montre-moi tous les écrans du module X », « liste les écrans de X », « planche des écrans », ou veut critiquer/auditer un module entier avec impeccable (enchaîne alors sur `/impeccable critique`)."
metadata:
  origin: kilio
---

# Écrans d'un module Kilio

Donne une vue complète d'un module : liste des routes + captures + planche contact.
Lecture seule : ne modifie jamais le code ni les données de Kilio.

## Étapes

1. **Lister** les écrans (à lancer depuis la racine du dépôt Kilio) :

   ```bash
   node "${CLAUDE_SKILL_DIR}/scripts/capturer-ecrans.mjs" <module> --liste
   ```

   Affiche chaque `page.tsx` du module → route, et signale les routes dynamiques.
   Sans argument de module : liste les modules disponibles.

2. **Lancer l'app avec des données plausibles.** Le sandbox cloud bloque Supabase :
   utiliser le rig de `e2e/run-instant-rig.sh` (faux Supabase `e2e/mock-supabase.mjs` +
   `next build && next start`, port 3100, lire `instant-nav.rig.md`). En local avec
   accès réseau, `npm run dev` suffit (port 3000, passer `--base http://localhost:3000`).
   Ne jamais écrire en base réelle.

3. **Capturer** :

   ```bash
   node "${CLAUDE_SKILL_DIR}/scripts/capturer-ecrans.mjs" <module> --base http://localhost:3100
   ```

   - Résultat dans `reports/ecrans/<module>/` : un PNG par écran × (mobile 390×844,
     desktop 1280×800) × (clair, sombre), plus `index.html` (planche contact) et
     `ecrans.json` (route, URL résolue, statut HTTP, titre).
   - Une route dynamique est résolue en suivant le premier lien correspondant trouvé
     sur la page parente ; si aucun lien n'existe (pas de données), elle est marquée
     « non résolue » : le dire, ne pas inventer de donnée.
   - Options : `--themes clair`, `--viewports mobile`, `--out <dossier>`.

4. **Présenter** : ouvrir/joindre `index.html` (ou les PNG clés), résumer en tableau
   les écrans, et signaler les écrans en erreur (statut ≥ 400, page vide, non résolue).

## Aller plus loin

Pour voir les écrans *pendant l'usage* (créer, éditer, archiver…) avec une capture par
action, utiliser le skill `kilio-parcours-utilisateur`.

## Enchaîner avec la critique impeccable

Quand l'utilisateur veut aussi la critique du module :

1. Faire les étapes 1 à 4 d'abord (les captures servent de preuve visuelle).
2. Lancer `/impeccable critique` sur le module, avec la liste des routes de
   `ecrans.json` comme cibles : une critique par écran clé, plus une synthèse sur la
   **cohérence entre écrans** (navigation, titres, espacements, états vides).
3. `impeccable critique` lance ses évaluations A (revue de design) et B (détecteur +
   navigateur) en sous-agents isolés : leur donner les URLs résolues, pas le module en
   vrac.
4. Ne corriger qu'après accord de l'utilisateur sur la synthèse.
