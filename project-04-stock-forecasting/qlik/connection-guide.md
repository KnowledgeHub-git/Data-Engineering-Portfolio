# Qlik Connection Guide — Project 04 Stock Forecasting

## Connection Settings

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Port** | `443` |
| **Database** | `ML_STOCKS` |
| **Schema** | `RESULTS` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |
| **User** | `BIWARO` |
| **Auth** | Username + Password |

## Recommended Load Script

```qvs
// =============================================================
// Qlik Sense Load Script — Stock Forecasting ML Results
// =============================================================

LIB CONNECT TO 'Snowflake_MLStocks';

// Technical indicators (full history with RSI, Bollinger, MACD)
TECHNICAL_INDICATORS:
LOAD *;
SQL SELECT
    TICKER,
    "DATE" AS TRADE_DATE,
    CLOSE_PRICE,
    HIGH_PRICE,
    LOW_PRICE,
    OPEN_PRICE,
    VOLUME,
    SMA_7,
    SMA_20,
    SMA_50,
    VOLATILITY_20D,
    BOLLINGER_UPPER,
    BOLLINGER_LOWER,
    RSI_14,
    MACD_APPROX,
    DAILY_RETURN
FROM ML_STOCKS.RESULTS.TECHNICAL_INDICATORS;

// 30-day forecast predictions with confidence intervals
FORECAST_PREDICTIONS:
LOAD *;
SQL SELECT
    SERIES AS TICKER,
    TS AS FORECAST_DATE,
    FORECAST AS PREDICTED_PRICE,
    LOWER_BOUND,
    UPPER_BOUND
FROM ML_STOCKS.RESULTS.FORECAST_PREDICTIONS;

// Detected anomalies in daily returns
ANOMALIES:
LOAD *;
SQL SELECT
    SERIES AS TICKER,
    TS AS ANOMALY_DATE,
    Y AS ACTUAL_RETURN,
    FORECAST AS EXPECTED_RETURN,
    IS_ANOMALY,
    PERCENTILE,
    DISTANCE
FROM ML_STOCKS.RESULTS.DETECTED_ANOMALIES
WHERE IS_ANOMALY = TRUE;
```

## Associative Model

| Qlik Table | Key Field | Links To |
|------------|-----------|----------|
| TECHNICAL_INDICATORS | `TICKER` | All tables linked by ticker |
| FORECAST_PREDICTIONS | `TICKER` | TECHNICAL_INDICATORS.`TICKER` |
| ANOMALIES | `TICKER` | TECHNICAL_INDICATORS.`TICKER` |

## Suggested Measures

```
// Current RSI
Only({<TRADE_DATE={"$(=Max(TRADE_DATE))"}>} RSI_14)

// Forecast vs Last Actual
Avg(PREDICTED_PRICE) - Max({<TRADE_DATE={"$(=Max(TRADE_DATE))"}>} CLOSE_PRICE)

// 20-day annualized volatility
Avg(VOLATILITY_20D) * Sqrt(252)

// Anomaly count per ticker
Count({<IS_ANOMALY={true}>} ANOMALY_DATE)

// Bollinger Band width
(BOLLINGER_UPPER - BOLLINGER_LOWER) / SMA_20
```

## Set Analysis

```
// Only anomalous dates
{<IS_ANOMALY={true}>}

// NVIDIA only
{<TICKER={'NVDA'}>}

// Overbought (RSI > 70)
{<RSI_14={">70"}>}
```
