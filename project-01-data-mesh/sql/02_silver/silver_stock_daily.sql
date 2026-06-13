/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: silver_stock_daily.sql
  Purpose: Pivot stock prices into a wide daily OHLCV format per ticker
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA SILVER;

CREATE OR REPLACE DYNAMIC TABLE silver_stock_daily
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Pivoted daily stock data — one row per ticker per date with OHLCV columns'
AS
SELECT
    TICKER,
    ASSET_CLASS,
    PRIMARY_EXCHANGE_CODE,
    DATE AS TRADE_DATE,
    MAX(CASE WHEN VARIABLE_NAME = 'Nasdaq Last Sale Price' OR VARIABLE_NAME = 'Post-Market Close' THEN VALUE END) AS CLOSE_PRICE,
    MAX(CASE WHEN VARIABLE_NAME = 'Nasdaq Opening Price' OR VARIABLE_NAME = 'Pre-Market Open' THEN VALUE END) AS OPEN_PRICE,
    MAX(CASE WHEN VARIABLE_NAME = 'Nasdaq High Price' THEN VALUE END) AS HIGH_PRICE,
    MAX(CASE WHEN VARIABLE_NAME = 'Nasdaq Low Price' THEN VALUE END) AS LOW_PRICE,
    MAX(CASE WHEN VARIABLE_NAME = 'Nasdaq Volume' THEN VALUE END) AS VOLUME,
    MAX(EVENT_TIMESTAMP_UTC) AS LAST_UPDATED_UTC
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_STOCK_PRICES
WHERE VARIABLE_NAME IN (
    'Nasdaq Last Sale Price',
    'Nasdaq Opening Price',
    'Nasdaq High Price',
    'Nasdaq Low Price',
    'Nasdaq Volume',
    'Post-Market Close',
    'Pre-Market Open'
)
GROUP BY TICKER, ASSET_CLASS, PRIMARY_EXCHANGE_CODE, DATE;
