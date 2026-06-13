/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: test_data_freshness.sql
  Purpose: Verify Dynamic Tables have refreshed recently
=============================================================================
*/

-- Check refresh timestamps for all Dynamic Tables in the database
SELECT
    SCHEMA_NAME,
    NAME AS DYNAMIC_TABLE_NAME,
    TARGET_LAG,
    DATA_TIMESTAMP AS LAST_REFRESHED,
    DATEDIFF('hour', DATA_TIMESTAMP, CURRENT_TIMESTAMP()) AS HOURS_SINCE_REFRESH,
    CASE
        WHEN DATEDIFF('hour', DATA_TIMESTAMP, CURRENT_TIMESTAMP()) > 48 THEN 'STALE'
        WHEN DATEDIFF('hour', DATA_TIMESTAMP, CURRENT_TIMESTAMP()) > 24 THEN 'WARNING'
        ELSE 'FRESH'
    END AS FRESHNESS_STATUS
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLES())
WHERE DATABASE_NAME = 'PORTFOLIO_DATA_MESH'
ORDER BY SCHEMA_NAME, NAME;

-- Check for null primary keys in gold layer (data quality)
SELECT 'gold_fact_stock_prices: NULL TICKER' AS TEST,
       COUNT(*) AS FAILURES
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
WHERE TICKER IS NULL OR TRADE_DATE IS NULL
UNION ALL
SELECT 'gold_dim_company: NULL COMPANY_ID',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_COMPANY
WHERE COMPANY_ID IS NULL
UNION ALL
SELECT 'gold_dim_calendar: NULL CALENDAR_DATE',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_CALENDAR
WHERE CALENDAR_DATE IS NULL
UNION ALL
SELECT 'gold_dim_geography: NULL GEO_ID',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_GEOGRAPHY
WHERE GEO_ID IS NULL;
