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

SET search_path TO pg_catalog,public,codelists,simple_features;
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


