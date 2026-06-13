/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: gold_wide_market_summary.sql
  Purpose: Wide market summary table — aggregated metrics per ticker for dashboards
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA GOLD;

CREATE OR REPLACE DYNAMIC TABLE gold_wide_market_summary
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Market summary — latest price, 30d performance, volume, per ticker'
AS
WITH latest_prices AS (
    SELECT
        TICKER,
        ASSET_CLASS,
        PRIMARY_EXCHANGE_CODE,
        TRADE_DATE,
        CLOSE_PRICE,
        OPEN_PRICE,
        HIGH_PRICE,
        LOW_PRICE,
        VOLUME,
        MA_7D,
        MA_30D,
        VOLATILITY_30D,
        DAILY_RETURN_PCT,
        ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY TRADE_DATE DESC) AS RN
    FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
),
price_30d_ago AS (
    SELECT
        TICKER,
        CLOSE_PRICE AS PRICE_30D_AGO,
        ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY TRADE_DATE DESC) AS RN
    FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
    WHERE TRADE_DATE <= DATEADD('day', -30, CURRENT_DATE())
)
SELECT
    lp.TICKER,
    lp.ASSET_CLASS,
    lp.PRIMARY_EXCHANGE_CODE,
    lp.TRADE_DATE AS LAST_TRADE_DATE,
    lp.CLOSE_PRICE AS LATEST_CLOSE,
    lp.OPEN_PRICE AS LATEST_OPEN,
    lp.HIGH_PRICE AS LATEST_HIGH,
    lp.LOW_PRICE AS LATEST_LOW,
    lp.VOLUME AS LATEST_VOLUME,
    lp.MA_7D,
    lp.MA_30D,
    lp.VOLATILITY_30D,
    lp.DAILY_RETURN_PCT AS LATEST_DAILY_RETURN,
    p30.PRICE_30D_AGO,
    CASE
        WHEN p30.PRICE_30D_AGO IS NOT NULL AND p30.PRICE_30D_AGO != 0
        THEN (lp.CLOSE_PRICE - p30.PRICE_30D_AGO) / p30.PRICE_30D_AGO
        ELSE NULL
    END AS RETURN_30D_PCT,
    CASE
        WHEN lp.CLOSE_PRICE > lp.MA_30D THEN 'ABOVE_MA30'
        WHEN lp.CLOSE_PRICE < lp.MA_30D THEN 'BELOW_MA30'
        ELSE 'AT_MA30'
    END AS TREND_SIGNAL
FROM latest_prices lp
LEFT JOIN price_30d_ago p30
    ON lp.TICKER = p30.TICKER AND p30.RN = 1
WHERE lp.RN = 1;
