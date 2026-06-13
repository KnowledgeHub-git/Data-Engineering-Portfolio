-- =============================================================
-- Project 02: Real-Time Weather Pipeline
-- Step 00: Infrastructure Setup
-- =============================================================

-- Domain database
CREATE DATABASE IF NOT EXISTS WEATHER_DOMAIN
  COMMENT = 'Weather domain - real-time pipeline POC with NWS/METAR data';

-- Schema hierarchy
CREATE SCHEMA IF NOT EXISTS WEATHER_DOMAIN.RAW
  COMMENT = 'Landing zone - time-windowed views on marketplace data';
CREATE SCHEMA IF NOT EXISTS WEATHER_DOMAIN.CURATED
  COMMENT = 'Dynamic Tables with tight lag for near-real-time aggregation';
CREATE SCHEMA IF NOT EXISTS WEATHER_DOMAIN.PRODUCTS
  COMMENT = 'Consumption layer - alerts, health, geographic rollups';

-- Dedicated warehouse for DT refreshes and alert checks
CREATE WAREHOUSE IF NOT EXISTS WEATHER_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Weather domain compute - Dynamic Table refreshes and alert checks';

-- Grant access to marketplace data
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_PUBLIC_DATA_FREE TO ROLE ACCOUNTADMIN;
