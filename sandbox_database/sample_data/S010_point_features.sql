-- Sample data for point_features

-- With fixed identifier (AKA uuid)
--      TRUNCATE apron._base_service_road;

\echo -------------------------------------------------------------------------
\echo -- CREATE feature on basedata.point_features


INSERT INTO basedata.point_features(
	identifier
    , name
    , wkb_point
    )
VALUES (
        '00000000-0000-0000-0000-000000000000'::uuid
        , 'Test point_feature '    -- name
        , ST_GeomFromText('POINT (24.949333611 60.184119444)')
);

\echo -------------------------------------------------------------------------
\echo -- READ basedata.point_features

SELECT identifier
    , name
FROM basedata.point_features
WHERE identifier = '00000000-0000-0000-0000-000000000000'::uuid;

\echo -------------------------------------------------------------------------
\echo -- UPDATE basedata.point_features

UPDATE basedata.point_features
    SET name = name || ' - Updated value'
WHERE identifier = '00000000-0000-0000-0000-000000000000'::uuid;

SELECT identifier
    , name
FROM basedata.point_features
WHERE identifier = '00000000-0000-0000-0000-000000000000'::uuid;

\echo -------------------------------------------------------------------------
\echo -- DELETE feature from basedata.point_features

DELETE FROM basedata.point_features
WHERE identifier = '00000000-0000-0000-0000-000000000000'::uuid;

SELECT identifier
    , name
FROM basedata.point_features;

-- ----------------------------------------------------------------------------
--  End of SQL script
-- ----------------------------------------------------------------------------