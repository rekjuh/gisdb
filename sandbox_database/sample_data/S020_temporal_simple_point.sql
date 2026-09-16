-- Sample data for point_features

-- Execute:  \ir sandbox_database/sample_data/S020_temporal_simple_point.sql

-- With fixed identifier (AKA uuid)
--      TRUNCATE apron._base_service_road;

\echo -------------------------------------------------------------------------
\echo -- CREATE feature on temporal.simple_point

INSERT INTO temporal.simple_point(
	identifier
    , name
    , wkb_point
    )
VALUES (
        '00000000-0000-0000-0000-000000000000'::uuid
        , 'Test simple_point'   -- name
        , ST_GeomFromText('POINT (24.949333611 60.184119444)')
);

\echo -------------------------------------------------------------------------
\echo -- DELETE feature from temporal.simple_point

DELETE FROM temporal.simple_point
WHERE identifier = '00000000-0000-0000-0000-000000000000'::uuid;



