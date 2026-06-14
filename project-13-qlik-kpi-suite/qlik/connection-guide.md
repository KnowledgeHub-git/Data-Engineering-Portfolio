# Qlik Cloud Connection — KPI Suite

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `KPI_SUITE` |
| Schema | `VIEWS` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Load Script

```qlik
//=============================================================
// KPI Suite - Executive Dashboard
// Connects to KPI_SUITE database (pre-aggregated views)
//=============================================================

LIB CONNECT TO 'Snowflake_KPI_Suite';

//--- DIMENSIONS ---

// Calendar Dimension
DIM_CALENDAR:
LOAD
    "DATE",
    "YEAR",
    "QUARTER",
    "MONTH",
    MONTH_NAME,
    "WEEK",
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKDAY,
    FISCAL_QUARTER,
    YEAR_MONTH
;
SQL SELECT * FROM KPI_SUITE.DIMENSIONS.DIM_CALENDAR;

// Company Dimension
DIM_COMPANY:
LOAD
    COMPANY_ID,
    COMPANY_NAME,
    TICKER,
    EXCHANGE,
    CIK,
    INDUSTRY,
    SIC_DESCRIPTION,
    STATE,
    CITY
;
SQL SELECT * FROM KPI_SUITE.DIMENSIONS.DIM_COMPANY;

//--- FACT TABLES ---

// Market KPIs (monthly stock performance)
MARKET_KPI:
LOAD
    TICKER,
    COMPANY_NAME,
    INDUSTRY,
    MONTH_DATE AS "DATE",
    "YEAR",
    "MONTH",
    TRADING_DAYS,
    AVG_CLOSE,
    MONTH_HIGH,
    MONTH_LOW,
    TOTAL_VOLUME,
    AVG_DAILY_RETURN_PCT,
    VOLATILITY_PCT
;
SQL SELECT * FROM KPI_SUITE.VIEWS.V_MARKET_KPI;

// Economic KPIs (macro indicators)
ECONOMY_KPI:
LOAD
    "DATE",
    "YEAR",
    "MONTH",
    INDICATOR,
    VALUE,
    UNIT,
    INDICATOR_GROUP
;
SQL SELECT * FROM KPI_SUITE.VIEWS.V_ECONOMY_KPI;

// Corporate KPIs (SEC-reported financials)
CORPORATE_KPI:
LOAD
    CIK,
    COMPANY_NAME,
    TICKER,
    INDUSTRY,
    FORM_TYPE,
    METRIC_TAG,
    MEASURE_DESCRIPTION,
    AMOUNT,
    PERIOD_END_DATE AS "DATE",
    "YEAR",
    "QUARTER",
    COVERED_QTRS
;
SQL SELECT * FROM KPI_SUITE.VIEWS.V_CORPORATE_KPI;
```

## Associative Model

Key fields that auto-link across tables in Qlik:

| Field | Links |
|-------|-------|
| `DATE` | DIM_CALENDAR ↔ MARKET_KPI ↔ ECONOMY_KPI ↔ CORPORATE_KPI |
| `TICKER` | DIM_COMPANY ↔ MARKET_KPI ↔ CORPORATE_KPI |
| `COMPANY_NAME` | DIM_COMPANY ↔ MARKET_KPI ↔ CORPORATE_KPI |
| `INDUSTRY` | DIM_COMPANY ↔ MARKET_KPI ↔ CORPORATE_KPI |
| `CIK` | DIM_COMPANY ↔ CORPORATE_KPI |

## Suggested Set Analysis Expressions

```qlik
// YoY comparison (current year vs prior year)
Sum({<YEAR={$(=Max(YEAR))}>} AVG_CLOSE) / Sum({<YEAR={$(=Max(YEAR)-1)}>} AVG_CLOSE) - 1

// Current quarter corporate revenue
Sum({<METRIC_TAG={'Revenues'}, QUARTER={$(=Max(QUARTER))}, YEAR={$(=Max(YEAR))}>} AMOUNT)

// Top 5 performers by monthly return
=Aggr(Avg(AVG_DAILY_RETURN_PCT), TICKER)

// Volatility ranking
=Rank(Avg(VOLATILITY_PCT))

// Latest CPI value
=Max({<INDICATOR_GROUP={'CPI'}>} VALUE)

// Unemployment trend (last 12 months)
Sum({<INDICATOR_GROUP={'Unemployment'}, DATE={">=$(=AddMonths(Max(DATE),-12))"}>} VALUE) / Count({<INDICATOR_GROUP={'Unemployment'}, DATE={">=$(=AddMonths(Max(DATE),-12))"}>} DATE)
```

## Suggested Dashboard Tabs

1. **Market Performance** — KPI cards (top performer, worst performer, avg return), line chart of AVG_CLOSE by month per ticker, volume bar chart
2. **Economic Indicators** — KPI cards (latest CPI, unemployment rate), time series by indicator group
3. **Corporate Financials** — Revenue by company (bar), assets vs liabilities (stacked bar), quarterly trend
