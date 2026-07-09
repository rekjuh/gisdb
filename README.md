# GIS database sample
This is sample database for geospatial data management

### TODO
- picture to document group roles

## General Admin scripts

With these scripts you can create following items:
- template GIS database
- Group roles for GIS database management
- Create GIS database from template database

Read more from [Admin Script -documentation](admin_scripts/README.md)

## Development and testing

For testing out any scripts on a local database, you may start up a local development database with `docker compose up -d` and then connect to it with
`psql -h localhost -p 5442 -U postgres -d postgres`.
