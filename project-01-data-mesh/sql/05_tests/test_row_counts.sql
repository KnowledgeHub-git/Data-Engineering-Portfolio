/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: test_row_counts.sql
  Purpose: Validate that all layers have data flowing through
=============================================================================
*/

-- Quick health check: each layer should have rows
SELECT 'BRONZE' AS LAYER, 'bronze_stock_prices' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_STOCK_PRICES
UNION ALL
SELECT 'BRONZE', 'bronze_company_index',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_COMPANY_INDEX
UNION ALL
SELECT 'BRONZE', 'bronze_federal_reserve',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_FEDERAL_RESERVE
UNION ALL
SELECT 'BRONZE', 'bronze_geography',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.BRONZE.BRONZE_GEOGRAPHY
UNION ALL
SELECT 'SILVER', 'silver_stock_daily',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_STOCK_DAILY
UNION ALL
SELECT 'SILVER', 'silver_company_enriched',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_COMPANY_ENRICHED
UNION ALL
SELECT 'SILVER', 'silver_economic_indicators',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_ECONOMIC_INDICATORS
UNION ALL
SELECT 'SILVER', 'silver_geography_dim',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.SILVER.SILVER_GEOGRAPHY_DIM
UNION ALL
SELECT 'GOLD', 'gold_fact_stock_prices',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
UNION ALL
SELECT 'GOLD', 'gold_dim_company',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_COMPANY
UNION ALL
SELECT 'GOLD', 'gold_dim_calendar',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_CALENDAR
UNION ALL
SELECT 'GOLD', 'gold_dim_geography',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_GEOGRAPHY
UNION ALL
SELECT 'GOLD', 'gold_wide_market_summary',
       COUNT(*)
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_WIDE_MARKET_SUMMARY
ORDER BY LAYER, TABLE_NAME;
