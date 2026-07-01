-- -----------------------------------------------------------------------------
--	Create group roles for gisdatabase
-- -----------------------------------------------------------------------------
--     History:
--        2025-12-10  First version                                   posikifi
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--  Note run this with psql, like
--         		\i admin_scripts\10_create_group_roles.sql
--		Win: 	\i admin_scripts/10_create_group_roles.sql
--  or
--          psql -f admin_scripts\10_create_group_roles.sql
-- -----------------------------------------------------------------------------

-- Check that role has create role rights

\unset role_rights

SELECT rolcreaterole AS role_rights FROM pg_roles WHERE rolname = current_user \gset

\if :role_rights
    --\echo 'Please proceed'
\else
    \echo 'NO CREATE ROLE RIGHTS'
	-- TODO add list of roles where you can have 
	\q
\endif

-- -----------------------------------------------------------------------------
-- Default settings
\ir 90_set_default_settings.sql

\if :{?gisdb_prefix}
	\echo Create group roles for :gisdb_prefix
\else 
	\echo Define gisdb_prefix -variable
	\q 
\endif

-- -----------------------------------------------------------------------------
-- *** DBAs
\o NUL
SELECT
	NOT EXISTS(SELECT 
		FROM pg_catalog.pg_roles 
		WHERE rolname = :'dbas' ) 
		AS no_role; \gset

\if :no_role
	\echo == Create role :dbas
	CREATE ROLE :dbas WITH
		NOINHERIT
		CREATEROLE
		CREATEDB
		NOLOGIN;
	\set role_comment 'DBAs group role for ':gisdb_prefix' databases':creation_comment
	COMMENT ON ROLE :dbas IS :'role_comment';
\endif

-- -----------------------------------------------------------------------------
-- *** Admins

SELECT
	NOT EXISTS(SELECT 
		FROM pg_catalog.pg_roles 
		WHERE rolname = :'admins' ) 
		AS no_role; \gset

\if :no_role
	\echo == Create role :admins
	CREATE ROLE :admins WITH
		NOINHERIT
		NOLOGIN;
	\set role_comment 'Administration group role for ':gisdb_prefix' databases':creation_comment
	COMMENT ON ROLE :admins IS :'role_comment';
\endif

-- -----------------------------------------------------------------------------
-- *** Editors

SELECT
	NOT EXISTS(SELECT 
		FROM pg_catalog.pg_roles 
		WHERE rolname = :'editors' ) 
		AS no_role; \gset


\if :no_role
	\echo == Create role :editors
	CREATE ROLE :editors WITH
		INHERIT
		NOLOGIN;
	\set role_comment 'Editor group role for ':gisdb_prefix' databases':creation_comment
	COMMENT ON ROLE :editors IS :'role_comment';
\endif

-- -----------------------------------------------------------------------------
-- *** Viewers

SELECT
	NOT EXISTS(SELECT 
		FROM pg_catalog.pg_roles 
		WHERE rolname = :'viewers' ) 
		AS no_role; \gset


\if :no_role
	\echo == Create role :viewers
	CREATE ROLE :viewers WITH
		INHERIT
		NOLOGIN;
	\set role_comment 'Viewer group role for ':gisdb_prefix' databases':creation_comment
	COMMENT ON ROLE :viewers IS :'role_comment';
\endif

-- ----------------------------------------------------------------------------- 
-- 	Grant group roles to other group roles

\echo == Grant roles to created group roles
GRANT :viewers TO :editors;

GRANT :editors TO :admins;
GRANT :editors TO :dbas;

GRANT :admins to :dbas;

GRANT :dbas TO azure_pg_admin;
GRANT :admins to azure_pg_admin;

\o 

-- Show information
\du+ :gisdb_prefix*

-- TODO echo next steps. Add people to different groups 
-- Suggestion to add people to groups

-- Unsetting variables
\unset role_comment
\ir 91_unset_variables.sql

-- ----------------------------------------------------------------------------- 
-- End of SQL script
-- -----------------------------------------------------------------------------