# Project 14 — Qlik AutoML Pipeline

Unified feature store that serves both Snowflake Cortex ML and Qlik AutoML, demonstrating the "feature store as shared resource" pattern.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | BI Developer + ML Engineer |
| **Snowflake Features** | Feature Store, CTAS, Cortex ML comparison |
| **Feature Tables** | 3 (stock direction, provider risk, climate risk) |
| **Total Rows** | 27,816 across all feature tables |
| **Models Tracked** | 4 trained (Cortex ML) + 3 pending (Qlik AutoML) |
| **Streamlit** | Deployed as `ML_DASHBOARD` |

## Architecture

```
ML_STOCKS (Project 04)        HEALTH_ML (Project 05)       CLIMATE_RISK (Project 06)
  TECHNICAL_INDICATORS           CLASSIFICATION_TRAINING      FEATURE_STORE_CLIMATE
        |                              |                           |
        v                              v                           v
AUTOML_PIPELINE.FEATURES
  STOCK_RETURN_FEATURES (12.8K)  PROVIDER_RISK_FEATURES (10K)  CLIMATE_RISK_FEATURES (5K)
  Target: DIRECTION (UP/DOWN)    Target: IS_DEACTIVATED (0/1)  Target: RISK_TIER (H/M/L)
        |                              |                           |
        +--------- Consumed by --------+---------------------------+
        |                                                          |
  Qlik AutoML (no-code)                              Cortex ML (trained models)
  Train in Qlik Cloud UI                             Already trained in Projects 04-06
```

## Feature Tables

| Table | Rows | Features | Target | Use Case |
|-------|------|----------|--------|----------|
| `STOCK_RETURN_FEATURES` | 12,816 | SMA ratios, RSI, Bollinger %B, MACD, volatility, volume ratio | DIRECTION | Classify next-day price direction |
| `PROVIDER_RISK_FEATURES` | 10,000 | years_active, gender, specialty, state, credentials | IS_DEACTIVATED | Predict provider attrition |
| `CLIMATE_RISK_FEATURES` | 5,000 | GHG totals (MT), sector shares (%) per country/year | RISK_TIER | Classify emissions risk level |

## Model Comparison

| Model | Platform | Type | Metrics |
|-------|----------|------|---------|
| STOCK_FORECAST_MODEL | Cortex ML | Forecast | RMSE: 12.4 |
| PRICE_ANOMALY_MODEL | Cortex ML | Anomaly Detection | Precision: 0.85 |
| DEACTIVATION_CLASSIFIER | Cortex ML | Classification | Accuracy: 0.89 |
| RISK_TIER_CLASSIFIER | Cortex ML | Classification | Accuracy: 1.00 |
| STOCK_DIRECTION_AUTOML | Qlik AutoML | Classification | Pending |
| PROVIDER_RISK_AUTOML | Qlik AutoML | Classification | Pending |
| CLIMATE_TIER_AUTOML | Qlik AutoML | Classification | Pending |

## Usage

Train Qlik AutoML models: connect to `AUTOML_PIPELINE.FEATURES` in Qlik Cloud > ML > Experiments. See `qlik/connection-guide.md` for step-by-step instructions.

## Credit Usage

~0.5 credits (3 CTAS operations + Streamlit deployment).
