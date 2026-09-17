# GIS database sample
This is a sample of QGIS versioned setup.

### Prequisites:
- Download and install QGIS versions under C:/Program Files/
- modify qgis/dev/qgis_start.cmd as needed

##
TO DO:

### Create:
- different sample .ini files
- different QGIS versions under Program Files: 3.x and 4.X
- sample data
- sample profiles
- sample projects
- sample plugins (that support QGIS 4.x, too)

### All of the following on QGIS 3.X:
- test that the qgis_start.cmd starts the wanted QGIS version
- test that the qgis_start.cmd starts the wanted versions of qgis_custom_ui.ini and qgis_global_settings.ini
- test that the qgis_start.cmd loads the wanted profiles
- try out sample profiles
- try out sample projects
- try out sample plugins

### Once all of the above work, do all of the following on QGIS 4.X:
- try out sample profiles
- try out sample projects
- try out sample plugins


## General Admin scripts

With these scripts you can create following items:
- template GIS database
- Group roles for GIS database management
- Create GIS database from template database

Read more from [Admin Script -documentation](admin_scripts/README.md)

## Development and testing

For testing out any scripts on a local database, you may start up a local development database with `docker compose up -d` and then connect to it with
`psql -h localhost -p 5442 -U postgres -d postgres`.

### TO DO
- Picture to document group roles
- Add GeoServer to the initial setup
- Combine the stack so that once run it will install QGIS, PostGIS database and GeoServer that are interconnected and contain sample data

