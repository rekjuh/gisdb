-- Prepended SQL commands --
--\set ON_ERROR_STOP ON

SET ROLE sandbox_admins;	

ALTER DEFAULT PRIVILEGES  
	GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES 
	TO sandbox_admins;

-- TODO should we decline delete on editors?
ALTER DEFAULT PRIVILEGES 
	GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES 
	TO sandbox_editors;

ALTER DEFAULT PRIVILEGES 
	GRANT SELECT ON TABLES 
	TO sandbox_viewers;

ALTER DEFAULT PRIVILEGES  
	GRANT USAGE, CREATE ON SCHEMAS
	TO sandbox_admins;

ALTER DEFAULT PRIVILEGES 
	GRANT USAGE ON SCHEMAS
	TO sandbox_viewers;
-- ddl-end ---- ** Database generated with pgModeler (PostgreSQL Database Modeler).
-- ** pgModeler version: 1.2.1
-- ** PostgreSQL version: 17.0
-- ** Project Site: pgmodeler.io
-- ** Model Author: ---

SET check_function_bodies = false;
-- ddl-end --

-- object: codelists | type: SCHEMA --
-- DROP SCHEMA IF EXISTS codelists CASCADE;
CREATE SCHEMA codelists;
-- ddl-end --

-- object: simple_features | type: SCHEMA --
-- DROP SCHEMA IF EXISTS simple_features CASCADE;
CREATE SCHEMA simple_features;
-- ddl-end --
COMMENT ON SCHEMA simple_features IS E'This database includes simple features';
-- ddl-end --

-- Appended SQL commands --
ALTER DEFAULT PRIVILEGES IN SCHEMA simple_features 
	GRANT SELECT ON TABLES 
	TO sandbox_viewers;

ALTER DEFAULT PRIVILEGES IN SCHEMA simple_features 
	GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES 
	TO sandbox_editors;

ALTER DEFAULT PRIVILEGES IN SCHEMA simple_features 
	GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES 
	TO sandbox_admins;
-- ddl-end --

-- object: metadata | type: SCHEMA --
-- DROP SCHEMA IF EXISTS metadata CASCADE;
CREATE SCHEMA metadata;
-- ddl-end --

-- object: basedata | type: SCHEMA --
-- DROP SCHEMA IF EXISTS basedata CASCADE;
CREATE SCHEMA basedata;
-- ddl-end --
COMMENT ON SCHEMA basedata IS E'Basic GIS data';
-- ddl-end --

-- object: temporal | type: SCHEMA --
-- DROP SCHEMA IF EXISTS temporal CASCADE;
CREATE SCHEMA temporal;
-- ddl-end --
COMMENT ON SCHEMA temporal IS E'Sample of temporal tables';
-- ddl-end --

SET search_path TO pg_catalog,public,codelists,simple_features,metadata,basedata,temporal;
-- ddl-end --

-- object: simple_features.my_first_point_layer | type: TABLE --
-- DROP TABLE IF EXISTS simple_features.my_first_point_layer CASCADE;
CREATE TABLE simple_features.my_first_point_layer (
	fid integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
	name varchar(200),
	wkb_geometry geometry(POINT, 3067),
	CONSTRAINT my_first_point_layer_pk PRIMARY KEY (fid)
);
-- ddl-end --
COMMENT ON COLUMN simple_features.my_first_point_layer.wkb_geometry IS E'2D point geometries EPSG:3067';
-- ddl-end --

-- object: simple_features.my_first_line_layer | type: TABLE --
-- DROP TABLE IF EXISTS simple_features.my_first_line_layer CASCADE;
CREATE TABLE simple_features.my_first_line_layer (
	fid integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
	name varchar(200),
	wkb_geometry geometry(LINESTRING, 3067),
	CONSTRAINT my_first_line_layer_pk PRIMARY KEY (fid)
);
-- ddl-end --
COMMENT ON COLUMN simple_features.my_first_line_layer.wkb_geometry IS E'2D linestring geometries EPSG:3067';
-- ddl-end --

-- object: simple_features.my_first_polygon_layer | type: TABLE --
-- DROP TABLE IF EXISTS simple_features.my_first_polygon_layer CASCADE;
CREATE TABLE simple_features.my_first_polygon_layer (
	fid integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
	name varchar(200),
	wkb_geometry geometry(POLYGON, 3067),
	CONSTRAINT my_first_polygon_layer_pk PRIMARY KEY (fid)
);
-- ddl-end --
COMMENT ON COLUMN simple_features.my_first_polygon_layer.wkb_geometry IS E'2D polygon geometries EPSG:3067';
-- ddl-end --

-- object: simple_features.pnt_layer_serial | type: TABLE --
-- DROP TABLE IF EXISTS simple_features.pnt_layer_serial CASCADE;
CREATE TABLE simple_features.pnt_layer_serial (
	fid serial NOT NULL,
	name varchar(200),
	wkb_geometry geometry(POINT, 3067),
	CONSTRAINT pnt_layer_pk PRIMARY KEY (fid)
);
-- ddl-end --
COMMENT ON TABLE simple_features.pnt_layer_serial IS E'Point layer with primary key as serial';
-- ddl-end --

-- object: basedata.point_features | type: TABLE --
-- DROP TABLE IF EXISTS basedata.point_features CASCADE;
CREATE TABLE basedata.point_features (
	identifier uuid NOT NULL DEFAULT gen_random_uuid(),
	name text,
	wkb_point geometry(POINT, 4326),
	CONSTRAINT point_features_pk PRIMARY KEY (identifier)
);
-- ddl-end --

-- object: metadata.history_logs | type: TABLE --
-- DROP TABLE IF EXISTS metadata.history_logs CASCADE;
CREATE TABLE metadata.history_logs (
	log_id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	logtime timestamptz,
	feature_identifier uuid,
	action text,
	username text,
	schema_name text,
	table_name text,
	old_data jsonb,
	new_data jsonb,
	CONSTRAINT history_logs_pk PRIMARY KEY (log_id)
);
-- ddl-end --

-- object: metadata.fn_log_history | type: FUNCTION --
-- DROP FUNCTION IF EXISTS metadata.fn_log_history() CASCADE;
CREATE OR REPLACE FUNCTION metadata.fn_log_history ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	PARALLEL UNSAFE
	COST 1
	AS 
$function$

BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO metadata.history_logs(logtime, feature_identifier, action, username, schema_name, table_name, new_data)
        VALUES (now(), NEW.identifier, 'INSERT', session_user, TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(NEW) );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        -- Soft-delete (deleted_at from NULL -> now())
       /*
        IF (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL) THEN
            INSERT INTO metadata.history_logs(logtime, feature_identifier, action, username, schema_name, table_name, old_data, new_data)
            VALUES (now(), OLD.identifier, 'SOFT-DELETE', session_user, TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(OLD), to_jsonb(NEW));
        ELSE */
        --  Regular update
        INSERT INTO metadata.history_logs(logtime, feature_identifier, action, username, schema_name, table_name, old_data, new_data)
            VALUES (now(), OLD.identifier, 'UPDATE', session_user, TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(OLD), to_jsonb(NEW));
        
   --END IF;

        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        -- If admin will hard delete object
	INSERT INTO metadata.history_logs(logtime, feature_identifier, action, username, schema_name, table_name, old_data)
	VALUES (now(), OLD.identifier, 'HARD-DELETE', session_user, TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(OLD));        

        RETURN OLD;

    END IF;
RETURN null;
END;
$function$;
-- ddl-end --

-- object: trg_log_history | type: TRIGGER --
-- DROP TRIGGER IF EXISTS trg_log_history ON basedata.point_features CASCADE;
CREATE OR REPLACE TRIGGER trg_log_history
	AFTER INSERT OR DELETE OR UPDATE
	ON basedata.point_features
	FOR EACH ROW
	EXECUTE PROCEDURE metadata.fn_log_history();
-- ddl-end --
COMMENT ON TRIGGER trg_log_history ON basedata.point_features IS E'Log all INSERT, DELETE and UPDATE to metadata.history_logs';
-- ddl-end --

-- object: temporal._base_simple_point | type: TABLE --
-- DROP TABLE IF EXISTS temporal._base_simple_point CASCADE;
CREATE TABLE temporal._base_simple_point (
	fid bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	identifier uuid NOT NULL DEFAULT gen_random_uuid(),
	name text,
	wkb_point geometry(POINT, 4326),
	valid_from timestamptz NOT NULL DEFAULT now(),
	valid_to timestamptz,
	CONSTRAINT _base_temporal_points_pk PRIMARY KEY (identifier,fid)
);
-- ddl-end --
COMMENT ON TABLE temporal._base_simple_point IS E'This is base table for temporal points';
-- ddl-end --

-- object: temporal.simple_point | type: VIEW --
-- DROP VIEW IF EXISTS temporal.simple_point CASCADE;
CREATE OR REPLACE VIEW temporal.simple_point
AS 
SELECT identifier, name, wkb_point 
FROM temporal._base_simple_point
WHERE valid_to IS NULL;
-- ddl-end --

-- object: temporal.fn_gis_temporal | type: FUNCTION --
-- DROP FUNCTION IF EXISTS temporal.fn_gis_temporal() CASCADE;
CREATE OR REPLACE FUNCTION temporal.fn_gis_temporal ()
	RETURNS trigger
	LANGUAGE plpgsql
	VOLATILE 
	CALLED ON NULL INPUT
	SECURITY INVOKER
	PARALLEL UNSAFE
	COST 1
	AS 
$function$
DECLARE
    v_pk_col text := TG_ARGV[0]; 
    v_schema text := TG_TABLE_SCHEMA; 
    v_table text := '_base_' || TG_TABLE_NAME;
    
    v_pk_val text;               
    v_col_names text;
    v_new_vals text;
    v_sql text;

BEGIN
    -- 1. Haetaan näkymän sarakkeet, mutta JÄTETÄÄN POIS temporal-sarakkeet
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT 
            -- Luo tekstin: "sarakkeen_nimi", "toinen_sarake"
            string_agg(quote_ident(attname), ', ' ORDER BY attnum),
            -- Luo tekstin: $1."sarakkeen_nimi", $1."toinen_sarake" (poimii datan NEW-riviltä)
            string_agg('$1.' || quote_ident(attname), ', ' ORDER BY attnum)
        INTO 
            v_col_names, 
            v_new_vals
        FROM pg_attribute
        WHERE attrelid = TG_RELID 
          AND attnum > 0 
          AND NOT attisdropped
          -- Tässä estetään tuplien syntyminen:
          AND attname NOT IN ('valid_from', 'valid_to', 'fid'); 
    END IF;

    -- 2. Kaivetaan ID
    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        v_pk_val := to_jsonb(OLD) ->> v_pk_col;
    END IF;

    -- 3. UUDEN LISÄYS
    IF TG_OP = 'INSERT' THEN
        v_sql := format(
            'INSERT INTO %I.%I (%s, valid_from, valid_to) SELECT %s, NOW(), NULL', 
            v_schema, v_table, v_col_names, v_new_vals
        );
        EXECUTE v_sql USING NEW;
        RETURN NEW;

    -- 4. PÄIVITYS
    ELSIF TG_OP = 'UPDATE' THEN
        v_sql := format(
            'UPDATE %I.%I SET valid_to = NOW() WHERE %I = %L AND valid_to IS NULL',
            v_schema, v_table, v_pk_col, v_pk_val
        );
        EXECUTE v_sql;

        v_sql := format(
            'INSERT INTO %I.%I (%s, valid_from, valid_to) SELECT %s, NOW(), NULL', 
            v_schema, v_table, v_col_names, v_new_vals
        );
        EXECUTE v_sql USING NEW;
        RETURN NEW;

    -- 5. POISTO
    ELSIF TG_OP = 'DELETE' THEN
        v_sql := format(
            'UPDATE %I.%I SET valid_to = NOW() WHERE %I = %L AND valid_to IS NULL',
            v_schema, v_table, v_pk_col, v_pk_val
        );
        EXECUTE v_sql;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$function$;
-- ddl-end --

-- object: trg_instead_of_simple_pooint | type: TRIGGER --
-- DROP TRIGGER IF EXISTS trg_instead_of_simple_pooint ON temporal.simple_point CASCADE;
CREATE OR REPLACE TRIGGER trg_instead_of_simple_pooint
	INSTEAD OF INSERT OR DELETE OR UPDATE
	ON temporal.simple_point
	FOR EACH ROW
	EXECUTE PROCEDURE temporal.fn_gis_temporal('identifier');
-- ddl-end --


