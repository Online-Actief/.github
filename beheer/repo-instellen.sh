#!/usr/bin/env bash
# Zet een repo van Online-Actief volgens de afspraken in CONTRIBUTING.md.
# Gebruik: beheer/repo-instellen.sh <repo>
# Nodig: gh, ingelogd als owner van de organisatie (scope admin:org).
# Mag vaker gedraaid worden; het resultaat is steeds hetzelfde.
set -euo pipefail

ORG=Online-Actief
REPO=${1:?Gebruik: $0 <repo>}
HIER=$(cd "$(dirname "$0")" && pwd)

echo "== $ORG/$REPO"

# Samenvoegen alleen met squash, branch na samenvoegen weg.
gh api -X PATCH "repos/$ORG/$REPO" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true -F allow_update_branch=true \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  --silent
echo "samenvoegen: alleen squash, branch na afloop verwijderd"

# Dependabot: waarschuwingen en beveiligingsupdates.
gh api -X PUT "repos/$ORG/$REPO/vulnerability-alerts" --silent
gh api -X PUT "repos/$ORG/$REPO/automated-security-fixes" --silent
echo "Dependabot: waarschuwingen en beveiligingsupdates aan"

# Labels die de meldingsformulieren gebruiken.
label() {
  gh api -X POST "repos/$ORG/$REPO/labels" -f name="$1" -f color="$2" -f description="$3" --silent 2>/dev/null \
    || gh api -X PATCH "repos/$ORG/$REPO/labels/$1" -f color="$2" -f description="$3" --silent
}
label fout d73a4a "Iets werkt niet zoals het hoort"
label wens 0e8a16 "Nieuwe functie of aanpassing"
echo "labels: fout, wens"

# Toegang via teams.
team() {
  gh api -X PUT "orgs/$ORG/teams/$1/repos/$ORG/$REPO" -f permission="$2" --silent
  echo "team $1: $2"
}
team developers maintain
team stagiairs-development push
team marketing push

# Regels voor main. Op privé-repo's alleen mogelijk met GitHub Team.
# Bij een fout geeft gh de foutmelding op stdout, dus alleen een geslaagde aanroep telt.
if ! bestaand=$(gh api "repos/$ORG/$REPO/rulesets" --jq '.[] | select(.name=="main beschermen") | .id' 2>/dev/null); then
  bestaand=""
fi
if [ -n "$bestaand" ]; then
  methode=(-X PUT "repos/$ORG/$REPO/rulesets/$bestaand")
else
  methode=(-X POST "repos/$ORG/$REPO/rulesets")
fi
if uitvoer=$(gh api "${methode[@]}" --input "$HIER/ruleset-main.json" 2>&1); then
  echo "regels voor main: actief"
else
  echo "regels voor main: NIET ingesteld"
  echo "  $uitvoer" | head -3
  echo "  (op het gratis plan kan dit alleen bij openbare repo's)"
fi
