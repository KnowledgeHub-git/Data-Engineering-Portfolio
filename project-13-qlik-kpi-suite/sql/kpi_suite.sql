-- Project 13: Qlik KPI Suite - Consumption views and dimensions for executive dashboard

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS KPI_SUITE
  COMMENT = 'Executive KPI dashboard - consumption views across Sales, Finance, Marketing domains';
CREATE SCHEMA IF NOT EXISTS KPI_SUITE.VIEWS;
CREATE SCHEMA IF NOT EXISTS KPI_SUITE.DIMENSIONS;

-- ============================================================
-- 2. DIMENSION TABLES
-- ============================================================

-- Master calendar for time intelligence
CREATE OR REPLACE TABLE KPI_SUITE.DIMENSIONS.DIM_CALENDAR AS
SELECT
    d.DATE_VAL AS "DATE",
    YEAR(d.DATE_VAL) AS "YEAR",
    QUARTER(d.DATE_VAL) AS "QUARTER",
    MONTH(d.DATE_VAL) AS "MONTH",
    MONTHNAME(d.DATE_VAL) AS MONTH_NAME,
    WEEKOFYEAR(d.DATE_VAL) AS "WEEK",
    DAYOFWEEK(d.DATE_VAL) AS DAY_OF_WEEK,
    DAYNAME(d.DATE_VAL) AS DAY_NAME,
    CASE WHEN DAYOFWEEK(d.DATE_VAL) BETWEEN 1 AND 5 THEN TRUE ELSE FALSE END AS IS_WEEKDAY,
    'Q' || QUARTER(d.DATE_VAL)::VARCHAR || ' ' || YEAR(d.DATE_VAL)::VARCHAR AS FISCAL_QUARTER,
    YEAR(d.DATE_VAL)::VARCHAR || '-' || LPAD(MONTH(d.DATE_VAL)::VARCHAR, 2, '0') AS YEAR_MONTH
FROM (SELECT DATEADD(DAY, SEQ4(), '2020-01-01'::DATE) AS DATE_VAL FROM TABLE(GENERATOR(ROWCOUNT => 2500))) d
WHERE d.DATE_VAL <= CURRENT_DATE();

-- Unified company dimension
CREATE OR REPLACE VIEW KPI_SUITE.DIMENSIONS.DIM_COMPANY AS
SELECT
    c.COMPANY_ID, c.COMPANY_NAME, c.PRIMARY_TICKER AS TICKER,
    c.PRIMARY_EXCHANGE_NAME AS EXCHANGE, c.CIK,
    COALESCE(i.INDUSTRY, 'Unknown') AS INDUSTRY,
    COALESCE(i.SIC_DESCRIPTION, 'Unknown') AS SIC_DESCRIPTION,
    COALESCE(i.STATE, 'Unknown') AS STATE,
    COALESCE(i.CITY, 'Unknown') AS CITY
FROM SALES_DOMAIN.PRODUCTS.COMPANY_MASTER c
LEFT JOIN MARKETING_DOMAIN.PRODUCTS.INDUSTRY_SEGMENTATION i ON c.COMPANY_ID = i.COMPANY_ID;

-- ============================================================
-- 3. KPI CONSUMPTION VIEWS
-- ============================================================

-- Market KPIs: monthly stock performance aggregates
CREATE OR REPLACE VIEW KPI_SUITE.VIEWS.V_MARKET_KPI AS
WITH monthly_agg AS (
    SELECT TICKER, DATE_TRUNC('MONTH', "DATE")::DATE AS MONTH_DATE,
        COUNT(*) AS TRADING_DAYS, ROUND(AVG(CLOSE_PRICE), 2) AS AVG_CLOSE,
        ROUND(MAX(HIGH_PRICE), 2) AS MONTH_HIGH, ROUND(MIN(LOW_PRICE), 2) AS MONTH_LOW,
        ROUND(SUM(VOLUME), 0) AS TOTAL_VOLUME,
        ROUND(AVG(DAILY_RETURN_PCT) * 100, 4) AS AVG_DAILY_RETURN_PCT,
        ROUND(STDDEV(DAILY_RETURN_PCT) * 100, 4) AS VOLATILITY_PCT
    FROM SALES_DOMAIN.PRODUCTS.STOCK_PERFORMANCE GROUP BY 1, 2
)
SELECT m.*, c.COMPANY_NAME, c.INDUSTRY, YEAR(m.MONTH_DATE) AS "YEAR", MONTH(m.MONTH_DATE) AS "MONTH"
FROM monthly_agg m LEFT JOIN KPI_SUITE.DIMENSIONS.DIM_COMPANY c ON m.TICKER = c.TICKER;

-- Economy KPIs: key macro indicators filtered from 50K rows
CREATE OR REPLACE VIEW KPI_SUITE.VIEWS.V_ECONOMY_KPI AS
SELECT "DATE", YEAR("DATE") AS "YEAR", MONTH("DATE") AS "MONTH",
    VARIABLE_NAME AS INDICATOR, VALUE, UNIT,
    CASE
        WHEN VARIABLE_NAME ILIKE '%CPI%All items%1982-84%' THEN 'CPI'
        WHEN VARIABLE_NAME ILIKE '%Unemployment Rate%' THEN 'Unemployment'
        WHEN VARIABLE_NAME ILIKE '%Average weekly earnings%all employees%total private%' THEN 'Wages'
        WHEN VARIABLE_NAME ILIKE '%GDP%' THEN 'GDP'
        WHEN VARIABLE_NAME ILIKE '%Consumer Credit%' THEN 'Consumer Credit'
        WHEN VARIABLE_NAME ILIKE '%Retail Sales%total%' THEN 'Retail Sales'
        ELSE 'Other'
    END AS INDICATOR_GROUP
FROM FINANCE_DOMAIN.PRODUCTS.ECONOMIC_DASHBOARD
WHERE VARIABLE_NAME ILIKE ANY ('%CPI%All items%1982-84%Seasonally%','%Unemployment Rate%Seasonally%',
    '%Average weekly earnings%all employees%total private%','%GDP%Real%Seasonally%',
    '%Consumer Credit%Total%Seasonally%','%Retail Sales%total%Seasonally%');

-- Corporate KPIs: key SEC-reported financials
CREATE OR REPLACE VIEW KPI_SUITE.VIEWS.V_CORPORATE_KPI AS
SELECT k.CIK, c.COMPANY_NAME, c.TICKER, c.INDUSTRY, k.FORM_TYPE, k.METRIC_TAG,
    k.MEASURE_DESCRIPTION, k.AMOUNT, k.PERIOD_END_DATE,
    YEAR(k.PERIOD_END_DATE) AS "YEAR", QUARTER(k.PERIOD_END_DATE) AS "QUARTER", k.COVERED_QTRS
FROM FINANCE_DOMAIN.PRODUCTS.CORPORATE_KPI k
LEFT JOIN KPI_SUITE.DIMENSIONS.DIM_COMPANY c ON k.CIK = c.CIK
WHERE k.METRIC_TAG IN ('Revenues','Assets','NetIncomeLoss','StockholdersEquity','Liabilities','OperatingIncomeLoss','CashAndCashEquivalentsAtCarryingValue');
