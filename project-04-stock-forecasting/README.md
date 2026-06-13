# Project 04 — Stock Price Forecasting

Time-series forecasting and anomaly detection on 10 major stocks using Snowflake Cortex ML, with SQL-based technical indicator engineering.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Cortex ML FORECAST, ANOMALY_DETECTION, Window Functions |
| **Source Data** | STOCK_PRICE_TIMESERIES (marketplace, 2018-2026) |
| **Tickers** | AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA, JPM, V, JNJ |
| **Feeds Into** | Project 10 (Market Agent), Project 14 (Qlik AutoML) |

## Architecture

```
SNOWFLAKE_PUBLIC_DATA_FREE.STOCK_PRICE_TIMESERIES (160M rows)
    │ Filter: 10 tickers
    ▼
ML_STOCKS.STAGING
    ├── DAILY_OHLCV (pivoted wide: Open/High/Low/Close/Volume)
    ├── FEATURE_ENGINEERED (SMA, RSI, Bollinger, MACD, volatility)
    ├── FORECAST_INPUT (date + close for Cortex ML)
    ├── ANOMALY_TRAIN (returns 2019-2025)
    └── ANOMALY_TEST (returns 2025-2026)
    │
    ▼
ML_STOCKS.MODELS
    ├── STOCK_FORECAST_MODEL (Cortex ML FORECAST, multi-series)
    └── PRICE_ANOMALY_MODEL (Cortex ML ANOMALY_DETECTION)
    │
    ▼
ML_STOCKS.RESULTS
    ├── FORECAST_PREDICTIONS (30-day predictions + 95% CI, 300 rows)
    ├── DETECTED_ANOMALIES (12 anomalies across 10 tickers)
    └── TECHNICAL_INDICATORS (RSI, Bollinger, MACD for all history)
```

## Key Deliverables

- [x] Cortex ML FORECAST: 30-day price predictions with confidence intervals
- [x] Cortex ML ANOMALY_DETECTION: flagged 12 unusual return events
- [x] Technical indicators via SQL window functions (RSI-14, Bollinger Bands, MACD, SMA-7/20/50)
- [x] Feature engineering pipeline (no Python UDFs needed)
- [x] Qlik connection guide with forecast visualization

## Technical Indicators Computed

| Indicator | Method | Window |
|-----------|--------|--------|
| SMA (7, 20, 50) | Simple Moving Average | 7/20/50 days |
| RSI-14 | Relative Strength Index | 14-day avg gain/loss |
| Bollinger Bands | SMA(20) +/- 2*StdDev | 20-day |
| MACD (approx) | SMA(12) - SMA(26) | 12/26 days |
| Volatility | StdDev of log returns | 20-day |

## Reproducing This Project

```bash
snowsql -f sql/00_setup/01_create_database.sql
snowsql -f sql/01_staging/feature_engineering.sql
snowsql -f sql/02_models/forecast_and_anomaly.sql
```

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md) for load script with forecast bands and anomaly markers.
