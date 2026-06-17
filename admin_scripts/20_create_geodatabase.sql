-- -----------------------------------------------------------------------------
--  Create geo database using common gisdb template datbase
-- -----------------------------------------------------------------------------
--  Notes
--   Run this with psql, like
--           \i admin_scripts\20_create_geodatabase.sql
--      Win: \i admin_scripts/20_create_geodatabase.sql
-- -----------------------------------------------------------------------------
\ir 90_set_default_settings.sql

-- Check that current_user have enough privileges to create database

SELECT rolcreatedb AS create_role FROM pg_roles WHERE rolname = current_user \gset

\if :create_role
    \echo == Creating geodatabase from selected common gisdb template database
\else
    \echo 'NO CREATE DATABASE RIGHTS'
	-- List group roles which current_user can use
    SELECT
        rolname AS "Use one of these group roles"
    FROM
        pg_roles
    WHERE
        rolcreatedb = true AND pg_has_role(current_user, rolname, 'MEMBER') AND rolname != current_user;
    \ir 91_unset_variables.sql
	\q
\endif

-- Default settings
\set ON_ERROR_STOP ON

-- \ir 90_set_default_settings.sql

SELECT CURRENT_USER as current_user \gset

--\set tmpl_dbname 'template_':gisdb_prefix
\set tmpl_dbname template_gisdb

-- Check if template exists
\o NUL
SELECT
	EXISTS(SELECT 1 FROM pg_database WHERE datname=:'tmpl_dbname' AND datistemplate) AS db_is_template;
\gset

\if :db_is_template
    \echo Found template database :tmpl_dbname
\else
    \echo Not found template database :tmpl_dbname
    \echo '  Please create first template database'
    \ir 91_unset_variables.sql
    \q
\endif

\echo :current_user
-- \q

\c postgres 
SET ROLE :current_user;

-- Select database version
\echo 'Define database version as following:'
\echo '  dev   Development database'
\echo '  test  Test database'
\echo '  prod  Production database '
\prompt 'Define version (dev|test|prod): ' db_version

-- TODO verify user input

-- uncomment after development phase
\o NUL       

SELECT to_char(now(), 'YYYYMMDD') AS version_date; \gset

\set target_db :gisdb_prefix'_':db_version'_v':version_date
-- ----------------------------------------------------------------------------- 
-- \o NUL       -- uncomment after development phase

\o NUL
SELECT
	EXISTS(SELECT 1 FROM pg_database WHERE datname=:'target_db') AS db_exists;
\gset

\if :db_exists
    \echo ERROR: Database :target_db already exists
    \echo '  Drop database and retry'
    \ir 91_unset_variables.sql
    \q
\endif

\echo Create geodatabase :target_db as :admins
CREATE DATABASE :target_db
    TEMPLATE = :tmpl_dbname
    OWNER = :admins;

SET ROLE :admins;
--ALTER DATABASE :target_db OWNER TO :admins;

ALTER DATABASE :target_db SET search_path TO "$user", qgis, public;

-- TODO Add comments to created database
SELECT 'Database for ' || :'gisdb_prefix' || ' database' || :'creation_comment'   AS db_comment; \gset
COMMENT ON DATABASE :target_db IS :'db_comment';

-- Revoke connection from public
REVOKE ALL ON DATABASE :target_db FROM PUBLIC;

-- Grant connection
GRANT CONNECT ON DATABASE :target_db TO :viewers;

-- ----------------------------------------------------------------------------- 
--  Setting privileges
--      NOTE: this was previously in template database

\c :target_db
-- SET ROLE :admins;
-- REASSIGN OWNED BY pg_database_owner TO :admins;
-- SET ROLE pg_database_owner;
-- REASSIGN OWNED BY pg_database_owner TO :admins;

-- SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'qgis') AS qgis_exists \gset
SELECT EXISTS(select 1 from pg_catalog.pg_namespace WHERE nspname = 'qgis') AS qgis_exists \gset

\if :qgis_exists
    \echo Update QGIS schema privileges...
    -- ALTER SCHEMA qgis OWNER TO :admins;
    GRANT USAGE ON SCHEMA qgis 
	    TO :viewers;
    GRANT SELECT ON ALL TABLES IN SCHEMA qgis
	    TO :viewers;
    ALTER DEFAULT PRIVILEGES IN SCHEMA qgis 
	    GRANT SELECT ON TABLES TO :viewers; 

    -- Grant rights to editors
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA qgis 
        TO :editors;
    ALTER DEFAULT PRIVILEGES IN SCHEMA qgis 
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES 
        TO :editors;

    -- Grant rights to admins
    GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA qgis 
        TO :admins;
    ALTER DEFAULT PRIVILEGES IN SCHEMA qgis 
        GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES 
        TO :admins;
\endif

SELECT EXISTS(select 1 from information_schema.tables WHERE table_name ='qgis_projects') AS qgis_projects \gset

\if :qgis_projects
    \echo ' Enable RowLevelSecurity to qgis.qgis_projects... '

    REVOKE UPDATE (project_owner) ON qgis.qgis_projects FROM :viewers;
    REVOKE UPDATE (project_owner) ON qgis.qgis_projects FROM :editors;

    ALTER TABLE qgis.qgis_projects
        ENABLE ROW LEVEL SECURITY;

    CREATE POLICY all_for_admin
        ON qgis.qgis_projects
        AS PERMISSIVE
        FOR ALL
        TO :admins
        USING (true) 
        WITH CHECK (true);

    CREATE POLICY select_for_all
        ON qgis.qgis_projects
        AS PERMISSIVE
        FOR SELECT
        TO public
        USING (true);

    CREATE POLICY insert_for_editors
        ON qgis.qgis_projects
        AS PERMISSIVE
        FOR INSERT
        TO :editors
        WITH CHECK (true);
	
    CREATE POLICY update_for_owner
        ON qgis.qgis_projects
        AS PERMISSIVE
        FOR UPDATE
        USING (session_user = project_owner);
	
    CREATE POLICY delete_for_owner
        ON qgis.qgis_projects
        AS PERMISSIVE
        FOR DELETE
        USING (session_user = project_owner);
\endif

-- Grant rights to QGIS layer_styles-table

/* SELECT EXISTS(select 1 from information_schema.tables WHERE table_name ='layer_styles') AS layer_styles \gset

\if :layer_styles
    \echo ' Granting access rights to QGIS layer styles -table '
    -- SET ROLE :admins;
    -- ALTER TABLE public.layer_styles OWNER TO :admins;
    GRANT SELECT ON TABLE qgis.layer_styles TO :viewers;
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE qgis.layer_styles TO :editors;
    GRANT ALL ON TABLE qgis.layer_styles TO :admins;
\endif

-- Grant rights to qgis_layer_metadata

SELECT EXISTS(select 1 from information_schema.tables WHERE table_name ='qgis_layer_metadata') AS qgis_metadata \gset

\if :qgis_metadata
    \echo ' Granting access rights to QGIS layer metadata -table '
    GRANT SELECT ON TABLE qgis.qgis_layer_metadata TO :viewers;
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE qgis.qgis_layer_metadata TO :editors;
    GRANT ALL ON TABLE qgis.qgis_layer_metadata to :admins;
\endif */

-- uncomment after development phase
\o           
-- ----------------------------------------------------------------------------- 
-- Unsetting variables

\ir 91_unset_variables.sql

-- ----------------------------------------------------------------------------- 
-- End of SQL script
-- -----------------------------------------------------------------------------