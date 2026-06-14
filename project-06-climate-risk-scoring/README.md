# Project 06 — Climate Risk Scoring

Composite climate risk scoring per country using emissions data, with Cortex ML CLASSIFICATION for risk tier prediction and a Feature Store for cross-project reuse.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Cortex ML CLASSIFICATION, Feature Store pattern, pivot aggregation |
| **Source Data** | CLIMATE_WATCH_TIMESERIES (1.5M), OUR_WORLD_IN_DATA (2.8M) |
| **POC Scope** | 5000 rows, 194 countries, 100% classifier accuracy |
| **Feeds Into** | Project 11 (Climate ESG Agent) |

## Architecture

```
Climate Watch + Our World in Data (Marketplace)
    │
    ▼
CLIMATE_RISK.STAGING
    ├── COUNTRY_EMISSIONS (150K, 50 top emitters from Climate Watch)
    ├── ENERGY_METRICS (280K, OWID per-capita indicators)
    ├── RISK_FEATURE_MATRIX (5000 rows, 194 countries, pivoted GHG by sector)
    └── CLASSIFIER_TRAINING (numeric features for ML)
    │
    ▼
CLIMATE_RISK.MODELS
    └── RISK_TIER_CLASSIFIER (Cortex ML, 100% accuracy on rule-based tiers)
    │
    ▼
CLIMATE_RISK.RESULTS
    ├── EMISSIONS_TRENDS (YoY % change per country)
    └── FEATURE_STORE_CLIMATE (governed, reusable: GHG + sector shares + risk tier)
```

## Key Results

- 194 countries scored across 3 risk tiers (High/Medium/Low)
- Classifier trained on 5000 rows with 100% accuracy
- Feature store ready for Project 11 (ESG Agent) consumption

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md)
