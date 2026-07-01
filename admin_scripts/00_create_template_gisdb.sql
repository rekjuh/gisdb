-- -----------------------------------------------------------------------------
--  Create template database to store geospatial information 
-- -----------------------------------------------------------------------------
--  Notes
--   Run this with psql, like
--              \i admin_scripts\00_create_template_gisdb.sql
--      Win:    \i admin_scripts/00_create_template_gisdb.sql
--
--   You need superuser privileges to install extensions (aka postgres user)
--  
-- If you need drop template_gisdb:
--      ALTER DATABASE template_gisdb IS_TEMPLATE false;
--      DROP DATABASE template_gisdb ;
-- -----------------------------------------------------------------------------

\set gisdb_prefix gisdb

-- Default settings
\ir 90_set_default_settings.sql

\set tmpl_dbname 'template_':gisdb_prefix

-- -----------------------------------------------------------------------------
-- Check that we have already group roles
-- -----------------------------------------------------------------------------

\o NUL
SELECT		
	NOT EXISTS(SELECT 1
		FROM pg_catalog.pg_roles 
		WHERE rolname = :'dbas' ) 
		AS no_dbas; \gset

\o

\if :no_dbas
    \echo ERROR: No database admin role, like :dbas

    \prompt 'Should I create group role (':dbas')? (Y): ' create_dbas
    \if :create_dbas
	    \echo == Create role :dbas
	    CREATE ROLE :dbas WITH
		    NOINHERIT
		    CREATEROLE
		    CREATEDB
		    NOLOGIN;
	    \set role_comment 'DBAs group role for ':gisdb_prefix' databases':creation_comment
	    COMMENT ON ROLE :dbas IS :'role_comment';
    \else
        \echo Not creating :dbas, exit...
        \ir 91_unset_variables.sql
        \q
    \endif
\endif

-- -----------------------------------------------------------------------------
-- Check if template database exists
\c postgres


\o NUL
SELECT
	EXISTS(SELECT 1 FROM pg_database WHERE datname=:'tmpl_dbname') AS db_exists;
\gset

SELECT
	EXISTS(SELECT 1 FROM pg_database WHERE datname=:'tmpl_dbname' AND datistemplate) AS db_is_template;
\gset

\o

-- Remove existing template database
-- Only owner of db can replace it
\if :db_exists
    \prompt 'Template database exists already (':tmpl_dbname'), replace it? (Y): ' replace_tempdb
    \if :replace_tempdb
	    -- \echo Db exists
	    \if :db_is_template	
		    -- \echo db is template
		    ALTER DATABASE :tmpl_dbname IS_TEMPLATE false;
	    \endif
	    DROP DATABASE IF EXISTS :tmpl_dbname;
    \else
        \echo Template database :tmpl_dbname not replaced
        \ir 91_unset_variables.sql
        \q
    \endif
\endif

-- -----------------------------------------------------------------------------
-- 	TODO add LC_Collate_LC_type from env variables
\o NUL
SET ROLE :dbas;

CREATE DATABASE :tmpl_dbname
	OWNER :dbas
	TEMPLATE template0
	ENCODING UTF8
	LC_COLLATE 'en_US.UTF-8'
	LC_CTYPE 'en_US.UTF-8'
	IS_TEMPLATE true;

SET ROLE :dbas;

SELECT 'Template database for ' || :'gisdb_prefix' || ' databases' || :'creation_comment'   AS db_comment; \gset
COMMENT ON DATABASE :tmpl_dbname IS :'db_comment';

ALTER DATABASE :tmpl_dbname OWNER TO :dbas;

GRANT ALL PRIVILEGES ON DATABASE :tmpl_dbname TO :dbas;
GRANT CONNECT ON DATABASE :tmpl_dbname TO :dbas;
-- GRANT CONNECT ON DATABASE :tmpl_dbname TO :viewers;

-- TODO: move ownerships of all objects to :admins?

\c :tmpl_dbname
SET ROLE :dbas;
\o NUL

SET ROLE 'azure_pg_admin';
SET pgaudit.log = 'NONE';

-- --------------------------------------------------------------------------
--	Install extensions

-- Check superuser rights
\o
SELECT rolsuper AS superuser_status FROM pg_roles WHERE rolname = current_user \gset

\if :superuser_status
    \echo 'Installing extensions'
	CREATE EXTENSION postgis;
	CREATE EXTENSION postgis_raster;
	CREATE EXTENSION pgcrypto;
	CREATE EXTENSION postgres_fdw;
	CREATE EXTENSION btree_gist;

	SELECT exists(select name from pg_available_extensions where name = 'pg_audit') AS install_pgaudit; \gset

	\if :install_pgaudit
		CREATE EXTENSION pgaudit;
	\endif
\else
    \echo 'You need superuser rights to install extensions'
\endif

\echo =  Revoke all access from public

REVOKE ALL ON DATABASE :tmpl_dbname FROM PUBLIC;

SET ROLE :dbas;

-- --------------------------------------------------------------------------
--	QGIS related objects

\echo Create QGIS projects schema...
CREATE SCHEMA qgis;

COMMENT ON SCHEMA qgis IS 'QGIS project file storage';

ALTER SCHEMA qgis OWNER TO pg_database_owner;

SET ROLE pg_database_owner;

GRANT CREATE,USAGE ON SCHEMA qgis TO pg_database_owner;

ALTER DEFAULT PRIVILEGES IN SCHEMA qgis 
	GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES 
	TO pg_database_owner;

\echo ' Create QGIS projects table'
CREATE TABLE qgis.qgis_projects
(
    name text COLLATE pg_catalog."default" NOT NULL,
    metadata jsonb,
    content bytea,
	project_owner text DEFAULT session_user,
    CONSTRAINT qgis_projects_pkey PRIMARY KEY (name)
);


-- Creating QGIS layer_styles -layer
\echo ' Create QGIS Layer styles table'
CREATE TABLE qgis.layer_styles(
	id integer GENERATED ALWAYS AS IDENTITY
	,f_table_catalog varchar
	,f_table_schema varchar
	,f_table_name varchar
	,f_geometry_column varchar 
	,styleName text
	,styleQML xml
	,styleSLD xml
	,useAsDefault boolean
	,description text
	,owner varchar(63) DEFAULT CURRENT_USER
	,ui xml
	,update_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP
	,type varchar
	,CONSTRAINT qgis_layer_styles_pkey PRIMARY KEY (id)
);
/*
-- Create QGIS Layer metadata -table
\echo ' Create QGIS Layer metadata table'
CREATE TABLE IF NOT EXISTS qgis.qgis_layer_metadata(
    id integer GENERATED ALWAYS AS IDENTITY,
    f_table_catalog varchar NOT NULL,
    f_table_schema varchar NOT NULL,
    f_table_name varchar NOT NULL,
    f_geometry_column varchar ,
    identifier text NOT NULL,
    title text NOT NULL,
    abstract text ,
    geometry_type varchar,
    extent geometry(Polygon,4326),
    crs varchar,
    layer_type varchar NOT NULL,
    qmd xml NOT NULL,
    owner varchar(63)  DEFAULT CURRENT_USER,
    update_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT qgis_layer_metadata_pkey PRIMARY KEY (id),
    CONSTRAINT qgis_layer_metadata_f_table_catalog_f_table_schema_f_table__key UNIQUE (f_table_catalog, f_table_schema, f_table_name, f_geometry_column, geometry_type, crs, layer_type)
);
*/

SET ROLE :dbas;

ALTER DATABASE :tmpl_dbname SET search_path TO "$user", qgis, public;

\c postgres

-- Show created template database
\o
\x on 
\l+ :tmpl_dbname
\x

-- ----------------------------------------------------------------------------- 
-- Unsetting variables

\ir 91_unset_variables.sql

-- ----------------------------------------------------------------------------- 
-- End of SQL script
-- -----------------------------------------------------------------------------