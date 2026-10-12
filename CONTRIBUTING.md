# Werkwijze

Zo werken we met code bij Online Actief. Dit geldt voor elke repo in deze organisatie, tenzij de README van een repo iets anders zegt.

## In het kort

1. Maak een branch vanaf `main`.
2. Maak je wijziging, test hem lokaal en werk `changelog.md` bij.
3. Open een pull request. De controles draaien automatisch.
4. Een developer bekijkt het. Na goedkeuring en groene controles gaat het naar `main`.
5. `main` is altijd wat live staat of live mag.

Niemand werkt rechtstreeks op `main`, ook developers niet.

## Eenmalig instellen

### Git en GitHub

- Een GitHub-account met tweestapsverificatie. Zonder 2FA kun je geen lid zijn van de organisatie.
- Git met je eigen naam en je werkadres:

  ```sh
  git config --global user.name "Voornaam Achternaam"
  git config --global user.email "naam@online-actief.nl"
  ```

  Voeg dat adres ook toe aan je GitHub-account (Settings > Emails), dan worden je commits aan jou gekoppeld.

### gitleaks

gitleaks controleert vóór elke commit of er een wachtwoord, token of sleutel in je wijziging staat.

- Windows: `winget install Gitleaks.Gitleaks`
- macOS: `brew install gitleaks`
- Linux: download van https://github.com/gitleaks/gitleaks/releases

Zet daarna in elke repo die je kloont de controle aan:

```sh
git config core.hooksPath .githooks
```

## Branches

Geef een branch een korte naam die zegt wat erin zit:

| Soort | Voorbeeld |
|---|---|
| Nieuwe functie | `functie/export-naar-excel` |
| Fout oplossen | `fix/datum-in-rapport` |
| Tekst of documentatie | `tekst/uitleg-inloggen` |
| Onderhoud, updates | `onderhoud/python-3-12` |

## Commits

- Schrijf in de gebiedende wijs wat de commit doet, bijvoorbeeld "Voeg export naar Excel toe" of "Herstel datum in weekrapport".
- Eén onderwerp per commit. Liever drie kleine commits dan één grote.
- Commit nooit gegenereerde bestanden, data, logs of `node_modules`/`vendor`/`venv`.

## Pull requests

- Vul het sjabloon in. Vooral "Hoe getest" is belangrijk, die leest de reviewer als eerste.
- Houd een pull request klein. Wat in een kwartier te bekijken is, wordt sneller goedgekeurd.
- Zijn de controles rood? Klik op "Details" voor de oorzaak. Los het op in dezelfde branch, de pull request wordt vanzelf bijgewerkt.
- Na het samenvoegen wordt de branch verwijderd.

## Geheimen

Wachtwoorden, API-sleutels, tokens en certificaten komen nooit in git, ook niet tijdelijk en ook niet in een privé-repo.

- Zet ze in `.env`. Dat bestand staat in `.gitignore`.
- Zet de naam van elke variabele (zonder waarde) in `.env.example`.
- De geheimen van Online Actief Bot staan per repo in de omgeving `bot`, die alleen vanaf `main` bruikbaar is. Een workflow in een eigen branch kan er niet bij.

Staat er toch een geheim in een commit? Meld het meteen bij Vincent. Alleen verwijderen uit git is niet genoeg. Het geheim staat nog in de geschiedenis en misschien in kopieën, dus het moet vervangen worden.

## Wat er niet in GitHub hoort

- `.env` en andere bestanden met geheimen
- databases, exports, back-ups en logs
- persoonsgegevens en gegevens van klanten van klanten
- gekochte plugins en thema's (licentie)

## Controles bij elke pull request

| Controle | Wat het doet |
|---|---|
| Geen geheimen | doorzoekt de hele geschiedenis met gitleaks |
| Tests | draait de tests van het project (Node, Python of PHP) en controleert de syntax |
| Codekwaliteit | ruff (Python), shellcheck (scripts) en hadolint (Dockerfile) zoeken echte fouten |
| Beveiliging | pip-audit en osv-scanner zoeken packages met bekende lekken, semgrep zoekt onveilige code |
| Review | Online Actief Bot leest de wijziging en zet opmerkingen bij de regels, ingedeeld in Blokkerend, Belangrijk en Klein |

De eerste vier moeten groen zijn voordat iets naar `main` kan. De review van de bot is een hulp en vervangt de controle door een developer niet. Opnieuw laten kijken of iets vragen: begin een reactie in de pull request met `@oa-bot`.

Is een melding vals? Zet het niet zomaar uit, maar leg in de pull request uit waarom, dan beslist de reviewer.

## Uitrollen

Wat op `main` staat, gaat niet vanzelf live.

1. Ga in de repo naar **Actions > Uitrollen > Run workflow**.
2. De workflow controleert dat het `main` is, dat de controles groen zijn en dat jij mag uitrollen.
3. De server haalt het verzoek binnen een minuut op, controleert het opnieuw en rolt uit.
4. Werkt de nieuwe versie niet, dan zet de server automatisch de vorige terug.

Wie mag uitrollen staat in de organisatievariabele `UITROLLERS`. Bij **Deployments** in de repo zie je wat er live staat, wie het uitrolde en wanneer.

## Review

De reviewer kijkt naar vijf dingen:

1. Doet de wijziging wat in de pull request staat, en niets anders?
2. Is beschreven hoe het getest is, en klopt dat?
3. Staan er geen geheimen, data of persoonsgegevens in?
4. Is de code te lezen voor iemand die het project niet kent?
5. Is `changelog.md` bijgewerkt?

Opmerkingen los je op in dezelfde branch. Ben je het niet eens met een opmerking, reageer dan in de pull request, dan blijft de afweging bewaard.

## Nieuw project

Alleen owners kunnen repo's maken.

1. Ga naar [github.com/new](https://github.com/new), kies bij Template `Online-Actief/repo-template`, eigenaar `Online-Actief` en zet de repo op **Private**.
2. Gebruik als naam dezelfde naam als de map op de server, in kleine letters met streepjes, bijvoorbeeld `oa-kluis`.
3. Draai `beheer/repo-instellen.sh <repo>` uit deze repo. Dat zet samenvoegen, Dependabot, labels, teams en de regels voor `main` goed.
4. Vul de README in en zet in `.github/dependabot.yml` de regels aan die bij het project horen.

Een bestaand project zonder sjabloon krijgt de controles via het tabblad Actions > New workflow > "Controles van Online Actief".

## Rechten

| Team | Recht |
|---|---|
| Developers | schrijven en pull requests goedkeuren |
| Stagiairs development | schrijven, alles via pull request |
| Marketing | schrijven, alles via pull request, bijvoorbeeld voor teksten |

Toegang loopt altijd via een team, nooit per persoon. Bij vertrek wordt iemand uit de organisatie verwijderd, zie procedure OA-ISMS-04.

## Hulp

Zie [SUPPORT.md](SUPPORT.md).
