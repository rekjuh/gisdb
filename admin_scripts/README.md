# Admin scripts

With these scripts you can create geospatial databases and related items.

## Template GIS database
Template GIS database will use general template to geospatial datastorage and also storage for QGIS projects, styles and metadata.

[```00_create_template_gisdb.sql```](00_create_template_gisdb.sql) -script will create template GIS database (like template_gisdb). It will include following items:
- Extensions: PosGIS, PostGIS Raster, pgCrypto, pgAudit (if installed in your server)
- QGIS related tables to store QGIS projects, Layer styles and metata

***NOTE:*** You have to have superuser privileges to run this script (extension installations).

These scripts are made to run in command-line enviroment with [psql](https://www.postgresql.org/docs/18/app-psql.html)

### Executing

Start your ```psql``` in root folder of this repo.

Then you can run script:
```
PS MyPath:> psql "service=pg17"
psql (17.3, server 17.7)
Type "help" for help.

postgres@postgres@localhost=# \i admin_scripts/00_create_template_gisdb.sql
```

## Create group roles for your GIS database
We follow a best practice that all database privileges and access are granted to PostgreSQL Group roles, not login roles.

For geospatial database we have following group roles:

- **\<name of GIS database>_dbas:** Database administrations
- **\<name of GIS database>_admins:** GIS database admin
- **\<name of GIS database>_editors:** GIS database editors
- **\<name of GIS database>_viewers:** GIS database viewers

Viewers can acces database and read information, Editors can edit geospatial information, Admins can maintain codelists and other configuration tables. DBAs can create new databases, manage access to databases and create new group roles.

### Creating new group roles

Run [```10_create_group_roles.sql```](10_create_group_roles.sql) -script in psql. In this example we will create group roles for ```geodb``` -database: script will prompt name of database:

```
PS MyPath:> psql "service=pg17"
psql (17.3, server 17.7)
Type "help" for help.

postgres@postgres@localhost=# \i admin_scripts/10_create_group_roles.sql
-- Defining default settings for gisdb databases
Name of the database: geodb
Create group roles for geodb
== Create role geodb_dbas
== Create role geodb_admins
== Create role geodb_editors
== Create role geodb_viewers
== Grant roles to created group roles
                                                       List of roles
    Role name     |                      Attributes                      |                   Description
------------------+------------------------------------------------------+--------------------------------------------------
 geodb_admins  | No inheritance, Cannot login                         | Administration group role for geodb databases+
                  |                                                      | Creation time:2025-12-15 15:53:00+02            +
                  |                                                      | Created by:postgres
 geodb_dbas    | No inheritance, Create role, Create DB, Cannot login | DBAs group role for geodb databases          +
                  |                                                      | Creation time:2025-12-15 15:53:00+02            +
                  |                                                      | Created by:postgres
 geodb_editors | Cannot login                                         | Editor group role for geodb databases        +
                  |                                                      | Creation time:2025-12-15 15:53:00+02            +
                  |                                                      | Created by:postgres
 geodb_viewers | Cannot login                                         | Viewer group role for geodb databases        +
                  |                                                      | Creation time:2025-12-15 15:53:00+02            +
                  |                                                      | Created by:postgres

Unset variables related to geodb
```

**Note**: Remember add login roles to group roles, like

```sql
 GRANT geodb_admins TO <YourLoginName>;
 GRANT geodb_editors TO <YourLoginName>;
 ```

## Create your GIS database
Next step will create GIS database from template GIS database and using group roles from previous phase.

**Note:** If you drop and re-create GIS database: you don't need re-create group roles.

Script will prompt of your selected name of the database (in this example ```geodb```) and then one of the following:
- dev   Database is for development work
- test  Database is for testing
- prod  This is production database

Script will also granting access rights group roles.

### Executing script
Run [```20_create_geodatabase.sql```](20_create_geodatabase.sql) in psql:

```psql
postgres@postgres@localhost=# \i admin_scripts/20_create_geodatabase.sql
-- Defining default settings for gisdb databases
Name of the database: geodb
== Creating geodatabase from selected common gisdb template database
Found template database template_gisdb
postgres
psql (17.3, server 17.7)
You are now connected to database "postgres" as user "postgres".
Define database version as following:
  dev   Development database
  test  Test database
  prod  Production database
Define version (dev|test|prod): test
Create geodatabase geodb_test_v20251215 as geodb_admins
psql (17.3, server 17.7)
You are now connected to database "geodb_test_v20251215" as user "postgres".
Update QGIS schema privileges...
 Enable RowLevelSecurity to qgis.qgis_projects...
 Granting access rights to QGIS layer styles -table
 Granting access rights to QGIS layer metadata -table
Unset variables related to geodb
postgres@geodb_test_v20251215@localhost=#
```

**Note:** you don't have any datamodel inside your database. You need to create GIS datamodel inside your GIS database.

Shortly: create datamodel with pgModeler, export datamodel to SQL file and execute SQL-file with psql.

## Sanbox database
For testing and learning, you can create ```sandbox``` database:

1. Create Group roles for ```sandbox``` with [```10_create_group_roles.sql```](10_create_group_roles.sql)
2. Create ```sandbox```-geodatabase with  [```20_create_geodatabase.sql```](20_create_geodatabase.sql)
3. Implement [```sandbox -datamodel```](..\sandbox_database\sandbox.dbm) with psql :

```psql
  postgres@sandbox_test_v20251215@localhost=# \i sandbox_database\export\sandbox_v01.sql
```

Use [pgModeler](https://pgmodeler.io/) to modify [```sandbox```](..\sandbox_database\sandbox.dbm)-datamodel. When modification is ready, export datamodel to SQL-file and then re-create database.

More information about [Sandbox database](..\sandbox_database\SANDBOX.md).




