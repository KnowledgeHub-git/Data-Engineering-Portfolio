/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: silver_geography_dim.sql
  Purpose: Clean geography data — standardize levels, filter to useful rows
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA SILVER;

CREATE OR REPLACE DYNAMIC TABLE silver_geography_dim
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Cleaned geography master — standardized level names, non-null GEO_IDs only'
AS
SELECT
    GEO_ID,
    TRIM(GEO_NAME) AS GEO_NAME,
    UPPER(TRIM(LEVEL)) AS GEO_LEVEL,
    ISO_NAME,
    ISO_ALPHA2,
    ISO_ALPHA3,
    ISO_NUMERIC_CODE,
    ISO_3166_2_CODE,
    CASE
        WHEN UPPER(LEVEL) = 'COUNTRY' THEN 1
        WHEN UPPER(LEVEL) IN ('STATE', 'PROVINCE') THEN 2
        WHEN UPPER(LEVEL) IN ('COUNTY', 'DISTRICT') THEN 3
        WHEN UPPER(LEVEL) IN ('CITY', 'TOWN', 'PLACE') THEN 4
        WHEN UPPER(LEVEL) IN ('ZIPCODE', 'POSTALCODE') THEN 5
        ELSE 6
    END AS GEO_LEVEL_DEPTH
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_GEOGRAPHY
WHERE GEO_ID IS NOT NULL
  AND GEO_NAME IS NOT NULL;
