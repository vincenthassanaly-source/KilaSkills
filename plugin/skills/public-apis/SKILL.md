---
name: public-apis
description: "Trouver et tester une API publique gratuite à partir de la liste communautaire public-apis/public-apis (plus de 1400 API classées par catégorie : météo, finance, animaux, géographie, actualités, etc.). Utiliser pour « cherche une API pour… », « y a-t-il une API gratuite de… », « liste les API sans clé », « teste l'API météo », « donne-moi la météo à… », « public api », ou toute demande de source de données ouverte. Indique l'authentification requise, HTTPS et CORS, puis teste l'API avec un appel réel."
metadata:
  origin: kilaskills
---

# API publiques

Aide à choisir et à tester une API gratuite à partir de la liste
[public-apis/public-apis](https://github.com/public-apis/public-apis).

## Où trouver la liste

1. Si le dépôt KilaSkills est présent avec ses sous-modules, lire
   `vendor/public-apis/README.md`.
2. Sinon, la télécharger : `curl -sS https://raw.githubusercontent.com/public-apis/public-apis/master/README.md`.

Le README est organisé en sections `### Catégorie`, chacune avec un tableau
`API | Description | Auth | HTTPS | CORS`. Extraire une catégorie avec :

```bash
awk '/^### Weather/{f=1;next} /^\*\*\[⬆ Back to Index/{f=0} f' README.md
```

## Marche à suivre

1. Identifier la catégorie qui correspond au besoin (`grep '^### '` liste les catégories).
2. Préférer, dans l'ordre : Auth = `No`, HTTPS = `Yes`, puis `apiKey` seulement si rien d'autre.
3. Proposer 1 à 3 API avec leur description et leur contrainte d'auth.
4. Tester avec un appel réel (`curl -sS -m 20`) avant de répondre, puis présenter le résultat
   en mots simples (unités, date du relevé).
5. Ne jamais demander ni stocker de clé d'API dans le chat. Si une clé est nécessaire, le dire
   et laisser l'utilisateur la fournir par un canal sûr.

## Exemple validé : météo (Open-Meteo, sans clé)

```bash
curl -sS -m 20 "https://api.open-meteo.com/v1/forecast?latitude=48.85&longitude=2.35&current=temperature_2m,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&forecast_days=3&timezone=Europe/Paris"
```

- Remplacer `latitude`, `longitude` et `timezone` selon le lieu (ex. Glencoe : 56.68, -5.10, `Europe/London`).
- `weather_code` suit les codes WMO : 0 dégagé, 1-2 peu nuageux, 3 couvert, 45-48 brouillard,
  51-67 bruine/pluie, 71-77 neige, 80-82 averses, 95-99 orage.
- Les valeurs sont celles de la grille météo : en montagne, il fait plus froid et plus venteux.

## Limites

- La liste est tenue par la communauté : une API peut être morte ou avoir changé ses règles.
  Si l'appel échoue, essayer une autre entrée de la même catégorie.
- Respecter les conditions d'usage (ex. Open-Meteo : usage non commercial).
