/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: bronze_stock_prices.sql
  Purpose: Dynamic Table mirroring STOCK_PRICE_TIMESERIES from public data
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA BRONZE;

CREATE OR REPLACE DYNAMIC TABLE bronze_stock_prices
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Raw stock price timeseries — ticker, variable (open/high/low/close/volume), date, value'
AS
SELECT
    TICKER,
    ASSET_CLASS,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    VARIABLE,
    VARIABLE_NAME,
    DATE,
    VALUE,
    EVENT_TIMESTAMP_UTC
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.STOCK_PRICE_TIMESERIES;
