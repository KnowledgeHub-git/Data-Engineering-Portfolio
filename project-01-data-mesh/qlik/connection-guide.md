# Qlik Connection Guide — Project 01

## Connecting Qlik Sense to the Gold Layer

### Option 1: Qlik Sense Desktop (ODBC)

1. Install the **Snowflake ODBC driver** from Snowflake downloads
2. Create a DSN (Data Source Name):
   - **Server:** `prb43560.snowflakecomputing.com`
   - **Port:** `443`
   - **Database:** `PORTFOLIO_DATA_MESH`
   - **Schema:** `GOLD`
   - **Warehouse:** `COMPUTE_WH`
   - **Role:** `ACCOUNTADMIN`
3. In Qlik Sense, create a new connection using ODBC and select the DSN

### Option 2: Qlik Cloud (Direct Query)

1. In Qlik Cloud, navigate to **Data Sources > Create**
2. Select **Snowflake** connector
3. Enter connection details:
   - Server: `prb43560.snowflakecomputing.com`
   - Database: `PORTFOLIO_DATA_MESH`
   - Schema: `GOLD`
   - Warehouse: `COMPUTE_WH`
   - Role: `ACCOUNTADMIN`
4. Authenticate with your Snowflake credentials

### Recommended Load Script

```qvs
// Qlik Sense Load Script for Portfolio Data Mesh Gold Layer
// Uses Direct Query for live data from Snowflake Dynamic Tables

LIB CONNECT TO 'Snowflake_Portfolio';

// Dimension: Company
DIM_COMPANY:
LOAD *;
SQL SELECT
    COMPANY_ID,
    COMPANY_NAME,
    PRIMARY_TICKER,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    EXCHANGE_REGION
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_COMPANY;

// Dimension: Calendar
DIM_CALENDAR:
LOAD *;
SQL SELECT
    CALENDAR_DATE,
    YEAR_NUM,
    MONTH_NUM,
    QUARTER_NUM,
    DAY_NAME,
    MONTH_NAME,
    IS_WEEKDAY,
    YEAR_QUARTER_LABEL,
    YEAR_MONTH_LABEL
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_CALENDAR;

// Dimension: Geography
DIM_GEOGRAPHY:
LOAD *;
SQL SELECT
    GEO_ID,
    GEO_NAME,
    GEO_LEVEL,
    ISO_NAME,
    ISO_ALPHA2
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_DIM_GEOGRAPHY
WHERE GEO_LEVEL_DEPTH <= 3;  // Country, State, County only for performance

// Fact: Stock Prices (use Direct Query for large table)
// For large volumes, consider incremental load or Direct Query mode
FACT_STOCK_PRICES:
LOAD *;
SQL SELECT
    TICKER,
    TRADE_DATE AS CALENDAR_DATE,  // Links to DIM_CALENDAR
    OPEN_PRICE,
    HIGH_PRICE,
    LOW_PRICE,
    CLOSE_PRICE,
    VOLUME,
    DAILY_RETURN_PCT,
    MA_7D,
    MA_30D,
    VOLATILITY_30D
FROM PORTFOLIO_DATA_MESH.GOLD.GOLD_FACT_STOCK_PRICES
WHERE TRADE_DATE >= '2020-01-01';  // Limit history for performance
```

### Associative Model Mapping

| Qlik Concept | Maps To |
|-------------|---------|
| TICKER field | Links FACT_STOCK_PRICES to DIM_COMPANY.PRIMARY_TICKER |
| CALENDAR_DATE field | Links FACT_STOCK_PRICES to DIM_CALENDAR.CALENDAR_DATE |
| Set Analysis `{<YEAR_NUM={2024}>}` | Filter by calendar dimension |
| Set Analysis `{<EXCHANGE_REGION={'US'}>}` | Filter by geography |

### Suggested Qlik Measures

```
// Year-to-date return
Sum(CLOSE_PRICE) / Sum(OPEN_PRICE) - 1

// Average daily volume
Avg(VOLUME)

// 30-day volatility (pre-computed in Snowflake)
Avg(VOLATILITY_30D)

// Count of trading days
Count(DISTINCT CALENDAR_DATE)
```
