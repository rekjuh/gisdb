# Sandbox for geospatial database

This is documentation about Sandbox geospatial databases.

## Purpose
Main purpose is to have playground for newusers to test and learn how to use geospatial data in PostGIS database.

## Create Sanbox database

Most easiest way to create Sanbox database is use psql command-line tool. You can try to use pgAdmin, but...

NOTE: samples are done in Windows enviroment with PowerShell console.

### Create group roles for Sanbox database 

Execute [`10_create_group_roles.sql`](..\admin_scripts\10_create_group_roles.sql) in psql terminal:

```console
\i admin_scripts\10_create_group_roles.sql
```

#### Add users to group roles
- Viewers to `sandbox_viewers`
- Editors to `sandbox_editors`
- Admins to `sandbox_admins`

### Create Sandbox database

Execute [`20_create_geodatabase.sql`](..\admin_scripts\20_create_geodatabase.sql) -script in psql console

```console
postgres@postgres@localhost=#  \i admin_scripts\20_create_geodatabase.sql
```

### Add data model to Sandbox database

Sandbox data model has created with pgModeler and database model is sandbox.dbm. 

Export of Sandbox datamodel is locate in export-directory

Execute export of the Sandbox datamodel in psql console:

```console
postgres@sandbox_test_v20251125@localhost=> \i sandbox_database/export/sandbox_v01.sql
```


