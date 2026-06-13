/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: gold_dim_company.sql
  Purpose: Company dimension — clean, typed, ready for joins to fact tables
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA GOLD;

CREATE OR REPLACE DYNAMIC TABLE gold_dim_company
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Company dimension — unique company grain with all identifiers and exchange info'
AS
SELECT
    COMPANY_ID,
    COMPANY_NAME,
    PRIMARY_TICKER,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    CIK,
    CIK_PADDED,
    EIN,
    PERMID_COMPANY_ID,
    LEI_COUNT,
    LEI_LIST,
    GLOBAL_TICKER_COUNT,
    CASE
        WHEN PRIMARY_EXCHANGE_CODE IN ('XNAS', 'XNYS', 'XASE') THEN 'US'
        WHEN PRIMARY_EXCHANGE_CODE IN ('XLON', 'XAMS', 'XPAR', 'XFRA') THEN 'EUROPE'
        WHEN PRIMARY_EXCHANGE_CODE IN ('XTKS', 'XHKG', 'XSHG', 'XSHE') THEN 'ASIA_PACIFIC'
        ELSE 'OTHER'
    END AS EXCHANGE_REGION
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_COMPANY_ENRICHED;
