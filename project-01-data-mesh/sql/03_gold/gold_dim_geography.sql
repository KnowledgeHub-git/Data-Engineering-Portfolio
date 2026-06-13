/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: gold_dim_geography.sql
  Purpose: Geography dimension — hierarchical, suitable for drill-down in BI tools
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA GOLD;

CREATE OR REPLACE DYNAMIC TABLE gold_dim_geography
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Geography dimension — hierarchical levels (Country > State > County > City)'
AS
SELECT
    GEO_ID,
    GEO_NAME,
    GEO_LEVEL,
    GEO_LEVEL_DEPTH,
    ISO_NAME,
    ISO_ALPHA2,
    ISO_ALPHA3,
    ISO_NUMERIC_CODE,
    ISO_3166_2_CODE
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_GEOGRAPHY_DIM;
