/*
=============================================================================
  Project 01 — Multi-Domain Data Mesh
  Script: gold_dim_calendar.sql
  Purpose: Calendar dimension from Snowflake public calendar data
=============================================================================
*/

USE DATABASE PORTFOLIO_DATA_MESH;
USE SCHEMA GOLD;

CREATE OR REPLACE DYNAMIC TABLE gold_dim_calendar
  TARGET_LAG = '1 day'
  WAREHOUSE = PORTFOLIO_WH
  COMMENT = 'Calendar dimension — daily grain with month/quarter/year attributes'
AS
WITH daily_calendar AS (
    SELECT DISTINCT
        PERIOD_START_DATE AS CALENDAR_DATE
    FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.CALENDAR_INDEX
    WHERE CALENDAR_ID = 'Day'
),
monthly AS (
    SELECT
        PERIOD_START_DATE,
        PERIOD_END_DATE,
        ANNUAL_PERIOD AS YEAR_NUM,
        ORDINAL_POSITION_IN_ANNUAL_PERIOD AS MONTH_NUM
    FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.CALENDAR_INDEX
    WHERE CALENDAR_ID = 'Month'
),
quarterly AS (
    SELECT
        PERIOD_START_DATE,
        PERIOD_END_DATE,
        ANNUAL_PERIOD AS YEAR_NUM,
        ORDINAL_POSITION_IN_ANNUAL_PERIOD AS QUARTER_NUM
    FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.CALENDAR_INDEX
    WHERE CALENDAR_ID = 'Quarter'
)
SELECT
    d.CALENDAR_DATE,
    YEAR(d.CALENDAR_DATE) AS YEAR_NUM,
    MONTH(d.CALENDAR_DATE) AS MONTH_NUM,
    DAY(d.CALENDAR_DATE) AS DAY_OF_MONTH,
    DAYOFWEEK(d.CALENDAR_DATE) AS DAY_OF_WEEK,
    DAYOFYEAR(d.CALENDAR_DATE) AS DAY_OF_YEAR,
    WEEKOFYEAR(d.CALENDAR_DATE) AS WEEK_OF_YEAR,
    QUARTER(d.CALENDAR_DATE) AS QUARTER_NUM,
    CASE DAYOFWEEK(d.CALENDAR_DATE)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS DAY_NAME,
    CASE MONTH(d.CALENDAR_DATE)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS MONTH_NAME,
    CASE WHEN DAYOFWEEK(d.CALENDAR_DATE) IN (0, 6) THEN FALSE ELSE TRUE END AS IS_WEEKDAY,
    YEAR(d.CALENDAR_DATE)::VARCHAR || '-Q' || QUARTER(d.CALENDAR_DATE)::VARCHAR AS YEAR_QUARTER_LABEL,
    YEAR(d.CALENDAR_DATE)::VARCHAR || '-' || LPAD(MONTH(d.CALENDAR_DATE)::VARCHAR, 2, '0') AS YEAR_MONTH_LABEL
FROM daily_calendar d
WHERE d.CALENDAR_DATE >= '2010-01-01'
  AND d.CALENDAR_DATE <= CURRENT_DATE();
