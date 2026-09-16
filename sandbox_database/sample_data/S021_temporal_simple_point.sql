-- Sample data for point_features

-- Execute:  \ir sandbox_database/sample_data/S021_temporal_simple_point.sql

-- With fixed identifier (AKA uuid)
--      TRUNCATE apron._base_service_road;

\echo -------------------------------------------------------------------------
\echo -- CREATE feature on temporal.simple_point

SELECT gen_random_uuid() AS temp_uuid; \gset

INSERT INTO temporal.simple_point(
	identifier
    , name
    , wkb_point
    )
VALUES (
        :'temp_uuid'::uuid
        , 'Test simple_point'   -- name
        , ST_GeomFromText('POINT (24.949333611 60.184119444)')
);

\echo -------------------------------------------------------------------------
\echo -- UPDATE feature from temporal.simple_point

UPDATE temporal.simple_point
    SET name = name || ' - Updated value'
WHERE identifier =  :'temp_uuid'::uuid;

SELECT identifier
    , name
FROM temporal.simple_point
WHERE identifier =  :'temp_uuid'::uuid;

\echo -------------------------------------------------------------------------
\echo -- DELETE feature from temporal.simple_point

DELETE FROM temporal.simple_point
WHERE identifier =  :'temp_uuid'::uuid;

\echo -------------------------------------------------------------------------
\echo -- List temporal data

SELECT * FROM temporal._base_simple_point
WHERE identifier =  :'temp_uuid'::uuid;

-- ----------------------------------------------------------------------------
--  End of SQL script
-- ----------------------------------------------------------------------------
