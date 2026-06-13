/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: bronze_geography.sql
  Purpose: Dynamic Table mirroring GEOGRAPHY_INDEX from public data
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA BRONZE;

CREATE OR REPLACE DYNAMIC TABLE bronze_geography
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Raw geography master — GEO_ID, name, level, ISO codes'
AS
SELECT
    GEO_ID,
    GEO_NAME,
    LEVEL,
    ISO_NAME,
    ISO_ALPHA2,
    ISO_ALPHA3,
    ISO_NUMERIC_CODE,
    ISO_3166_2_CODE
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.GEOGRAPHY_INDEX;
