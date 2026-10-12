#!/usr/bin/env bash
# Zet een repo van Online-Actief volgens de afspraken in CONTRIBUTING.md.
# Gebruik: beheer/repo-instellen.sh <repo> [--zonder-regels]
# Nodig: gh, ingelogd als owner van de organisatie (scope admin:org).
# Mag vaker gedraaid worden; het resultaat is steeds hetzelfde.
set -euo pipefail

ORG=Online-Actief
REPO=${1:?Gebruik: $0 <repo> [--zonder-regels]}
ZONDER_REGELS=${2:-}
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

# Labelnamen met spaties of dubbele punten in een URL.
urlnaam() { local n=${1// /%20}; echo "${n//:/%3A}"; }

# Labels voor meldingen, prio, risico en categorie.
label() {
  gh api -X POST "repos/$ORG/$REPO/labels" -f name="$1" -f color="$2" -f description="$3" --silent 2>/dev/null \
    || gh api -X PATCH "repos/$ORG/$REPO/labels/$(urlnaam "$1")" -f color="$2" -f description="$3" --silent
}
# Meldingen
label fout d73a4a "Iets werkt niet zoals het hoort"
label wens 0e8a16 "Nieuwe functie of aanpassing"
# Prio en risico, gezet door Online Actief Bot bij elke review
label "prio: hoog" d73a4a "Snel bekijken: blokkerende punten of een beveiligingsfix"
label "prio: middel" fb8c00 "Normaal tempo"
label "prio: laag" 2da44e "Kan wachten"
label "risico: hoog" b60205 "Raakt login, rechten, data, database of uitrol"
label "risico: middel" e99695 "Raakt de werking van de app"
label "risico: laag" c2e0c6 "Tekst, documentatie, tests of opmaak"
# Categorie
label functie 1f6feb "Nieuwe functie of uitbreiding"
label beveiliging 8250df "Beveiliging"
label onderhoud 6e7781 "Updates, opruimen, instellingen"
label documentatie 0075ca "README, uitleg, changelog"
label tests bfd4f2 "Tests toevoegen of verbeteren"
# De Engelse standaardlabels van GitHub zijn dubbel met bovenstaande, die gaan weg.
for oud in accessibility bug documentation duplicate enhancement "good first issue" "help wanted" invalid question wontfix; do
  gh api -X DELETE "repos/$ORG/$REPO/labels/$(urlnaam "$oud")" --silent 2>/dev/null || true
done
echo "labels: meldingen, prio, risico en categorie"

# Omgeving "bot" met de geheimen van Online Actief Bot, alleen bruikbaar vanaf main.
# Een workflow uit een andere branch kan er niet bij.
GEHEIM=${OA_GEHEIMEN:-$HOME/oa-github/secrets}
gh api -X PUT "repos/$ORG/$REPO/environments/bot" --input - --silent <<JSON
{"deployment_branch_policy": {"protected_branches": false, "custom_branch_policies": true}}
JSON
if ! gh api "repos/$ORG/$REPO/environments/bot/deployment-branch-policies" --jq '.branch_policies[].name' | grep -qx main; then
  gh api -X POST "repos/$ORG/$REPO/environments/bot/deployment-branch-policies" -f name=main -f type=branch --silent
fi
for paar in "CLAUDE_CODE_OAUTH_TOKEN:claude-token.txt" "OA_BOT_PRIVATE_KEY:oa-bot.pem" "RESEND_API_KEY:resend.txt"; do
  naam=${paar%%:*}; bestand="$GEHEIM/${paar#*:}"
  if [ -s "$bestand" ]; then
    gh secret set "$naam" --env bot --repo "$ORG/$REPO" < "$bestand"
  else
    echo "LET OP: $bestand ontbreekt, $naam niet gezet"
  fi
done
echo "omgeving bot: alleen main, geheimen gezet"

# Toegang via teams.
team() {
  gh api -X PUT "orgs/$ORG/teams/$1/repos/$ORG/$REPO" -f permission="$2" --silent
  echo "team $1: $2"
}
team developers maintain
team stagiairs-development push
team marketing push

# Regels voor main. Op privé-repo's alleen mogelijk met GitHub Team.
# Met --zonder-regels blijven de huidige regels staan, bijvoorbeeld als er nog PR's open staan.
if [ "$ZONDER_REGELS" = "--zonder-regels" ]; then echo "regels voor main: niet aangepast"; exit 0; fi
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
