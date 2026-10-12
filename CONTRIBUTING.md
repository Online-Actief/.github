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

Beide moeten groen zijn voordat iets naar `main` kan.

## Rechten

| Team | Recht |
|---|---|
| Developers | schrijven en pull requests goedkeuren |
| Stagiairs development | schrijven, alles via pull request |
| Marketing | schrijven, alles via pull request, bijvoorbeeld voor teksten |

Toegang loopt altijd via een team, nooit per persoon. Bij vertrek wordt iemand uit de organisatie verwijderd, zie procedure OA-ISMS-04.
