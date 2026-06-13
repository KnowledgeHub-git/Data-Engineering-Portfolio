/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: tasks.sql
  Purpose: Create tasks for monitoring and alerting on pipeline health
  Note: Dynamic Tables handle their own refresh — tasks here are for
        monitoring, data quality checks, and custom aggregation triggers.
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA ORCHESTRATION;

-- Task: Daily data freshness check
-- Runs every morning at 8 AM UTC and logs whether gold tables refreshed
CREATE OR REPLACE TASK task_check_data_freshness
  WAREHOUSE = PORTFOLIO_WH
  SCHEDULE = 'USING CRON 0 8 * * * UTC'
  COMMENT = 'Daily check: verify gold Dynamic Tables have refreshed within last 48 hours'
AS
CALL SYSTEM$LOG_TRACE(
    'DATA_FRESHNESS_CHECK',
    'Checking gold layer refresh status at ' || CURRENT_TIMESTAMP()::VARCHAR
);

-- Task: Alert on missing stock data (triggered by stream)
-- Only runs when new data arrives in the stock prices stream
CREATE OR REPLACE TASK task_monitor_stock_gaps
  WAREHOUSE = PORTFOLIO_WH
  SCHEDULE = 'USING CRON 0 */6 * * * UTC'
  COMMENT = 'Every 6 hours: check for tickers missing price data in last 5 business days'
  WHEN SYSTEM$STREAM_HAS_DATA('ORCHESTRATION.STREAM_BRONZE_STOCK_PRICES')
AS
BEGIN
    -- Log tickers with gaps
    LET gap_count INTEGER;
    SELECT COUNT(DISTINCT TICKER) INTO :gap_count
    FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
    WHERE TRADE_DATE >= DATEADD('day', -7, CURRENT_DATE())
    GROUP BY TICKER
    HAVING COUNT(*) < 3;

    IF (:gap_count > 0) THEN
        CALL SYSTEM$LOG_TRACE(
            'STOCK_GAP_ALERT',
            :gap_count::VARCHAR || ' tickers have fewer than 3 trading days in last 7 days'
        );
    END IF;
END;

-- Resume tasks (they start suspended by default)
-- Uncomment when ready to activate:
-- ALTER TASK task_check_data_freshness RESUME;
-- ALTER TASK task_monitor_stock_gaps RESUME;
