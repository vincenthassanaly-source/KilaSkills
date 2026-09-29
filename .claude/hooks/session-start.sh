#!/bin/bash
# Met à jour le marketplace et les plugins kilaskills/ecc au démarrage d'une session web,
# pour que tous les skills du dépôt (plugin/skills/*) soient disponibles.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

MARKETPLACE="kilaskills-marketplace"

# Idempotent : ajoute le marketplace s'il est absent, sinon le rafraîchit.
if ! claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE"; then
  claude plugin marketplace add "${CLAUDE_PROJECT_DIR:-.}" || true
fi
claude plugin marketplace update "$MARKETPLACE" || true

for plugin in kilaskills ecc; do
  if claude plugin list 2>/dev/null | grep -q "${plugin}@${MARKETPLACE}"; then
    claude plugin update "${plugin}@${MARKETPLACE}" || true
  else
    claude plugin install "${plugin}@${MARKETPLACE}" || true
  fi
done
exit 0
