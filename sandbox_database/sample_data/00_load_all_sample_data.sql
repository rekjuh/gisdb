-- Load all sample data to database

-- Run in windows pgsql
--      \i sandbox_database/sample_data/00_load_all_samples.sql

\set ON_ERROR_ROLLBACK on

\echo =========================================================================
\echo  Features on basedata.point_features
BEGIN;

SET LOCAL ROLE sandbox_editors;
\ir S010_point_features.sql

COMMIT;