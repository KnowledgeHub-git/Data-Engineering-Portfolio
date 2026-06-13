/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: silver_company_enriched.sql
  Purpose: Clean company data — trim names, flatten arrays, add sector context
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA SILVER;

CREATE OR REPLACE DYNAMIC TABLE silver_company_enriched
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Cleaned company master — standardized names, flattened identifiers'
AS
SELECT
    COMPANY_ID,
    TRIM(COMPANY_NAME) AS COMPANY_NAME,
    ENTITY_LEVEL,
    EIN,
    LPAD(CIK, 10, '0') AS CIK_PADDED,
    CIK,
    PERMID_COMPANY_ID,
    UPPER(TRIM(PRIMARY_TICKER)) AS PRIMARY_TICKER,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    ARRAY_SIZE(COALESCE(LEI, ARRAY_CONSTRUCT())) AS LEI_COUNT,
    ARRAY_TO_STRING(COALESCE(LEI, ARRAY_CONSTRUCT()), ', ') AS LEI_LIST,
    ARRAY_SIZE(COALESCE(GLOBAL_TICKERS, ARRAY_CONSTRUCT())) AS GLOBAL_TICKER_COUNT
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_COMPANY_INDEX
WHERE COMPANY_NAME IS NOT NULL;
