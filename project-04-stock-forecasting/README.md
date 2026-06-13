# Project 04 — Stock Price Forecasting

Time-series forecasting and anomaly detection on stock prices using Snowflake Cortex ML, with custom Snowpark Python UDFs for technical indicator engineering.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Cortex ML (FORECAST, ANOMALY_DETECTION), Snowpark Python, Model Registry |
| **Source Data** | gold_fact_stock_prices (from Project 01), FX_RATES_TIMESERIES, FEDERAL_RESERVE |
| **Depends On** | Project 01 (gold layer stock data) |
| **Feeds Into** | Project 10 (Market Research Agent), Project 14 (Qlik AutoML) |

## Key Deliverables

- [ ] Cortex ML FORECAST for multi-step price prediction
- [ ] Cortex ML ANOMALY_DETECTION on price movements
- [ ] Snowpark UDFs for RSI, Bollinger Bands, MACD
- [ ] Feature engineering pipeline using window functions
- [ ] Model Registry for version tracking
- [ ] Qlik dashboard: forecasts vs actuals with confidence intervals

## How This Fits in the 15-Project Plan

First ML project — bridges the gap from data engineering to data science. The trained models and feature store outputs feed the Market Research Agent (Project 10) and provide Qlik AutoML with pre-engineered features (Project 14).
