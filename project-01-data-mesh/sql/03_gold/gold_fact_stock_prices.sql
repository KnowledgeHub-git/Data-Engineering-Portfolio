/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: gold_fact_stock_prices.sql
  Purpose: Fact table — daily stock prices with technical indicators
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA GOLD;

CREATE OR REPLACE DYNAMIC TABLE gold_fact_stock_prices
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Fact table — daily OHLCV per ticker with rolling technical indicators'
AS
SELECT
    s.TICKER,
    s.TRADE_DATE,
    s.ASSET_CLASS,
    s.PRIMARY_EXCHANGE_CODE,
    s.OPEN_PRICE,
    s.HIGH_PRICE,
    s.LOW_PRICE,
    s.CLOSE_PRICE,
    s.VOLUME,
    s.LAST_UPDATED_UTC,

    -- Daily return
    (s.CLOSE_PRICE - LAG(s.CLOSE_PRICE) OVER (PARTITION BY s.TICKER ORDER BY s.TRADE_DATE))
        / NULLIF(LAG(s.CLOSE_PRICE) OVER (PARTITION BY s.TICKER ORDER BY s.TRADE_DATE), 0)
    AS DAILY_RETURN_PCT,

    -- Moving averages
    AVG(s.CLOSE_PRICE) OVER (
        PARTITION BY s.TICKER ORDER BY s.TRADE_DATE
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS MA_7D,

    AVG(s.CLOSE_PRICE) OVER (
        PARTITION BY s.TICKER ORDER BY s.TRADE_DATE
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS MA_30D,

    -- Volatility (30-day rolling std dev of daily returns)
    STDDEV(
        (s.CLOSE_PRICE - LAG(s.CLOSE_PRICE) OVER (PARTITION BY s.TICKER ORDER BY s.TRADE_DATE))
        / NULLIF(LAG(s.CLOSE_PRICE) OVER (PARTITION BY s.TICKER ORDER BY s.TRADE_DATE), 0)
    ) OVER (
        PARTITION BY s.TICKER ORDER BY s.TRADE_DATE
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS VOLATILITY_30D,

    -- Volume moving average
    AVG(s.VOLUME) OVER (
        PARTITION BY s.TICKER ORDER BY s.TRADE_DATE
        ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
    ) AS AVG_VOLUME_20D

FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_STOCK_DAILY s
WHERE s.CLOSE_PRICE IS NOT NULL;
