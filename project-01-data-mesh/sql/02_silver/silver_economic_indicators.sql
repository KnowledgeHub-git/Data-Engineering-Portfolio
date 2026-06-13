/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: silver_economic_indicators.sql
  Purpose: Filter Federal Reserve data to key macro indicators (Fed Funds Rate,
           GDP, unemployment rate, CPI) and add descriptive metadata
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA SILVER;

CREATE OR REPLACE DYNAMIC TABLE silver_economic_indicators
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Filtered Federal Reserve timeseries — key macro indicators with clean types'
AS
SELECT
    GEO_ID,
    VARIABLE,
    VARIABLE_NAME,
    DATE AS OBSERVATION_DATE,
    VALUE AS INDICATOR_VALUE,
    UNIT,
    CASE
        WHEN VARIABLE_NAME ILIKE '%federal funds%' THEN 'INTEREST_RATE'
        WHEN VARIABLE_NAME ILIKE '%gross domestic product%' THEN 'GDP'
        WHEN VARIABLE_NAME ILIKE '%unemployment%' THEN 'EMPLOYMENT'
        WHEN VARIABLE_NAME ILIKE '%consumer price%' OR VARIABLE_NAME ILIKE '%inflation%' THEN 'INFLATION'
        WHEN VARIABLE_NAME ILIKE '%treasury%' THEN 'TREASURY'
        WHEN VARIABLE_NAME ILIKE '%money supply%' OR VARIABLE_NAME ILIKE '%M1%' OR VARIABLE_NAME ILIKE '%M2%' THEN 'MONEY_SUPPLY'
        ELSE 'OTHER'
    END AS INDICATOR_CATEGORY
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_FEDERAL_RESERVE
WHERE VALUE IS NOT NULL
  AND DATE IS NOT NULL;
