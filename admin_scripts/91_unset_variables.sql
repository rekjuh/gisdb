-- -----------------------------------------------------------------------------
--  Unset variables
-- -----------------------------------------------------------------------------
--  History:
--      2025-10-12  First version                                   posikifi
-- -----------------------------------------------------------------------------
--  Note run this with psql, like
--          \i admin_scripts\91_unset_variables.sql
--  or from other scripts
--          \ir 91_unset_variables.sql
-- -----------------------------------------------------------------------------

\if :{?gisdb_prefix}
	\echo Unset variables related to :gisdb_prefix
\else
    \echo gisdb_prefix -variable is not set. Check variable manually
    \q
\endif

-- Unset group role variables
\unset viewers 
\unset editors 
\unset devs 
\unset admins 
\unset dbas 

\unset gisdb_prefix

\unset created_at
\unset created_by
\unset creation_comment

-- ----------------------------------------------------------------------------- 
-- End of SQL script
-- -----------------------------------------------------------------------------