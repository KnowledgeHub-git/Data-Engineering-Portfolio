/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: bronze_federal_reserve.sql
  Purpose: Dynamic Table mirroring FEDERAL_RESERVE_TIMESERIES from public data
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA BRONZE;

CREATE OR REPLACE DYNAMIC TABLE bronze_federal_reserve
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Raw Federal Reserve timeseries — economic indicators by geography and date'
AS
SELECT
    GEO_ID,
    VARIABLE,
    VARIABLE_NAME,
    DATE,
    VALUE,
    UNIT
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.FEDERAL_RESERVE_TIMESERIES;
