/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: bronze_company_index.sql
  Purpose: Dynamic Table mirroring COMPANY_INDEX from public data
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA BRONZE;

CREATE OR REPLACE DYNAMIC TABLE bronze_company_index
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Raw company master — identifiers (CIK, EIN, LEI, PermID), tickers, exchanges'
AS
SELECT
    COMPANY_ID,
    COMPANY_NAME,
    ENTITY_LEVEL,
    EIN,
    CIK,
    LEI,
    PERMID_COMPANY_ID,
    PRIMARY_TICKER,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    GLOBAL_TICKERS
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.COMPANY_INDEX;
