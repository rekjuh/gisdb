# GIS database sample
This is a sample of **QGIS versioned setup**.
The main purpose of this repo is to try out migration from QGIS 3.x to 4.x. 

Files you can configure:
- qgis_start.cmd files (QGIS version & environment variables)
- global_settings.ini (override QGIS default settings)
- QGIS profile directories (override global settings)
- pgservice.conf (database connections)
- custom Python scripts (more variables and running Python at QGIS startup)

This repo is based on a gisdb repo that also includes PostGIS database, which isn't used here (yet). Feel free to improve and/or create a PR or an issue.

## Prequisites:
- Download and install wanted QGIS versions under C:/Program Files/
- Most of the parameters will be in this repo.

## Instructions:
1. Download this repo
2. modify qgis/dev/qgis_start.cmd files as needed
3. modify other parameters as needed
4. run qgis_start.cmd

## Hands-on user instructions for end users
See documentation for versioned QGIS setup ("QGIS keskitetty asennus") in Google Drive (search yourself).

# Summary in Finnish (Päivitetty 6.11.2026)

**Tavoite:** 
1. testata QGIS 3.44 keskitetty asennus tietyillä konfiguraatioilla. 
2. Kun se toimii, muuttaa skripti niin, että se ajaakin QGIS 4:ää. 
3. Tutkia versiopäivitykset vaikutusta, kirjata havainnot (mikä toimii, mikä menee rikki, muut huomiot).
4. Tutkia eri konfiguraatiotiedostojen keskinäisiä suhteita: mikä yliajaa toisen, kirjata havainnot

Skriptin pitäisi ajaa seuraavat:
- QGIS 3.44 LTR
- custom-profiili (käyttäjä ja admin)
- tietyt lisäosat
- kustoimitu käyttöliittymä
- rajapintayhteyksiä
    - avoimia ja tunnistautumista vaativia
- tietokantayhteksiä (lokaalisti)
- 3.44:ssä luotu QGIS-projektitiedosto testinä
- Python-konsolin piilottaminen

## To do:
- ks. yllä oleva lista
- admin-profiili
- skriptit, joilla voi ajaa käyttäjä- ja admin-profiilit QGIS 3.x:ssa
- skriptit, joilla voi ajaa käyttäjä- ja admin-profiilit QGIS 4.x:ssa
- visuaalisesti kompleksinen testiaineisto (esim. MML maastokartta)
- 3.x:llä luotu QGIS-projekti, jota testataan molemmissa QGIS-versioissa

-----

## Memos from original gisdb repo:

### PostGIS: general Admin scripts

With these scripts you can create following items:
- template GIS database
- Group roles for GIS database management
- Create GIS database from template database

Read more from [Admin Script -documentation](admin_scripts/README.md)

### Development and testing

For testing out any scripts on a local database, you may start up a local development database with `docker compose up -d` and then connect to it with
`psql -h localhost -p 5442 -U postgres -d postgres`.

### TO DO
- Picture to document group roles
- Add GeoServer to the initial setup
- Combine the stack so that once run it will install QGIS, PostGIS database and GeoServer that are interconnected and contain sample data

