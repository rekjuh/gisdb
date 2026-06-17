-- -----------------------------------------------------------------------------
--  Default settings for all kind of automatic scripts
-- -----------------------------------------------------------------------------
--  History:
--      2025-12-10      First version                            posikifi
-- -----------------------------------------------------------------------------
--  Note run this with psql, like
--          \i admin_scripts\90_set_default_settings.sql
--  or from other scripts
--          \ir 90_set_default_settings.sql
-- -----------------------------------------------------------------------------
--  Developer note
--      Add also settings to admin_scripts\91_unset_variables.sql

-- -----------------------------------------------------------------------------
\echo -- Defining default settings for gisdb databases

-- -----------------------------------------------------------------------------
-- Some def variables for script
\o NUL

SELECT date_trunc('minute', now()) AS created_at; \gset
SELECT session_user AS created_by; \gset

\set creation_comment '\nCreation time:' :created_at '\nCreated by:' :created_by

-- -----------------------------------------------------------------------------
--  database name and setting group role names

\set ON_ERROR_STOP ON

\if :{?gisdb_prefix}
	\echo Using :gisdb_prefix as prefix
\else
    \prompt 'Name of the database: ' gisdb_prefix
\endif

SELECT lower(:'gisdb_prefix') AS gisdb_prefix; \gset

\set viewers :gisdb_prefix '_viewers'
\set editors :gisdb_prefix '_editors'
\set admins :gisdb_prefix '_admins'
\set dbas :gisdb_prefix '_dbas'

\o
-- ----------------------------------------------------------------------------- 
-- End of SQL script
-- -----------------------------------------------------------------------------