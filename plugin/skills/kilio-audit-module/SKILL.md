---
name: kilio-audit-module
description: "Auditer un module Kilio de bout en bout : liste et capture tous ses écrans (mobile, clair + sombre), puis utilise l'app comme un vrai utilisateur avec une capture d'écran après CHAQUE action (créer, éditer, cocher, archiver, recharger…), relève erreurs console, requêtes en échec, débordements et écritures en base, produit un rapport unique (écrans au repos + pellicule d'usage + problèmes) et termine par une critique /impeccable critique du module. Utiliser quand l'utilisateur dit « audite le module X », « teste le module X comme un utilisateur », « montre-moi tous les écrans de X », « trouve les bugs d'usage de X » ou « critique le module X avec les captures »."
metadata:
  origin: kilio
---

# Audit d'un module Kilio

Un seul flux : **écrans au repos → usage réel avec captures → rapport → critique impeccable**.
Mobile uniquement (l'app est pensée pour téléphone). Aucune écriture en base réelle.

Scripts, à lancer depuis la racine du dépôt Kilio, avec `${CLAUDE_SKILL_DIR}/scripts/` :
`ecrans.mjs` (écrans au repos), `parcours.mjs` (usage réel), `rapport.mjs` (rapport unique).
Sortie : `reports/audit/<module>/` (`ecrans/`, `parcours/<nom>/`, `index.html`).

## 0. Préparer l'environnement

Lancer l'app contre le **faux Supabase**, jamais la base réelle : `e2e/run-instant-rig.sh`
(app sur le port 3100, faux Supabase sur 54321, voir `instant-nav.rig.md`). Le sandbox
cloud bloque Supabase, et le rig désactive le verrou biométrique du journal
(`E2E_VERROU_DESACTIVE=1`). En local avec réseau, `npm run dev` suffit (`--base
http://localhost:3000`). Sans argument de module, `ecrans.mjs` liste les modules disponibles.

## 1. Écrans au repos

```bash
node "${CLAUDE_SKILL_DIR}/scripts/ecrans.mjs" <module> --liste          # routes du module
node "${CLAUDE_SKILL_DIR}/scripts/ecrans.mjs" <module> --base http://localhost:3100
```

Une capture par écran en mobile clair et mobile sombre (`--themes clair` pour un seul).
Les routes dynamiques (`[id]`) sont résolues niveau par niveau en suivant le premier lien
de la page parente ; sans donnée, elles sont marquées « non résolue » : le dire, ne pas
inventer. Si des données manquent, compléter seulement les fixtures de test
(`e2e/mock-supabase.mjs`) et le signaler.

## 2. Usage réel, avec une capture par action

1. **Comprendre le module** : lire `src/app/(app)/<module>/`, ses composants, ses actions
   serveur et les `reports/*<module>*` (choix déjà tranchés : ne pas les remettre en cause).
2. **Écrire les parcours** en JSON dans `reports/audit/<module>/scenarios/` (un fichier par
   parcours, 5 à 15 étapes) : chemin nominal (créer, modifier, terminer, archiver/supprimer),
   persistance (`reload` puis `expect_text`), cas limites (champ vide, texte très long, double
   clic, retour arrière, liste vide). Format détaillé en en-tête de `scripts/parcours.mjs` :

   ```json
   { "nom": "creer-tache", "theme": "clair", "etapes": [
     { "action": "goto", "url": "/taches", "note": "ouvrir" },
     { "action": "fill", "cible": "role=textbox[name=/nouvelle/i]", "valeur": "Acheter du pain" },
     { "action": "click", "cible": "role=button[name=/ajouter/i]" },
     { "action": "expect_text", "texte": "Acheter du pain" } ] }
   ```

   Actions : goto, click, dblclick, hover, fill, press, select, check, uncheck, scroll,
   wait, reload, back, expect_text, expect_absent, screenshot. Cibles : sélecteurs
   Playwright, de préférence par rôle accessible ; une cible introuvable pour un utilisateur
   est déjà un problème d'accessibilité à signaler.
3. **Lancer** :

   ```bash
   node "${CLAUDE_SKILL_DIR}/scripts/parcours.mjs" reports/audit/<module>/scenarios \
     --base http://localhost:3100 --mock http://localhost:54321 --reset \
     --out reports/audit/<module>/parcours
   ```

   Une capture après chaque étape ; relevé des erreurs console, requêtes en échec, HTTP ≥ 400,
   débordement horizontal et écritures du faux Supabase.
4. **Regarder les captures** (Read) des étapes en anomalie ou en échec et de la dernière étape
   de chaque parcours : le script ne voit pas un libellé ambigu, un bouton trop petit, un état
   de chargement qui reste.

## 3. Rapport unique

```bash
node "${CLAUDE_SKILL_DIR}/scripts/rapport.mjs" <module>
```

Produit `reports/audit/<module>/index.html` : problèmes, écrans au repos, pellicule d'usage.
Résumer à l'utilisateur, classé par gravité : étape ou écran, capture, attendu vs observé,
cause probable dans le code, correction proposée. Distinguer un vrai bug d'un artefact du
faux Supabase (donnée absente du mock).

## 4. Critique impeccable (dernière étape)

Lancer `/impeccable critique` sur le module en lui donnant : la liste des routes résolues
(`ecrans/ecrans.json`), les captures au repos, la pellicule d'usage et les problèmes du
rapport. Une critique par écran clé, plus une synthèse sur la **cohérence entre écrans**
(navigation, titres, espacements, états vides, clair/sombre). Garder les évaluations A et B
d'impeccable en sous-agents isolés.

## Règles

- Lecture seule : ne corriger ni le code ni les données du module avant accord de l'utilisateur.
  Pour un bug confirmé, proposer un test Playwright de non-régression dans `e2e/`.
- Dire ce qui n'a pas pu être testé : base réelle, caméra (scanner), notifications, verrou
  biométrique, gestes tactiles fins. Le ressenti d'usage reste un jugement, à signaler comme tel.
