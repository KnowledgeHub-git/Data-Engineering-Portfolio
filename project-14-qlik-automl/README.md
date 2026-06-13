# Project 14 — Qlik AutoML Pipeline

End-to-end ML pipeline where Snowflake provides feature engineering and Qlik AutoML trains models, with predictions written back to Snowflake.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | BI Developer + ML |
| **Snowflake Features** | Feature Store, Dynamic Tables, Qlik AutoML, Writeback |
| **Source Data** | Feature Store outputs from Project 06, STOCK_PRICE from Project 01 |
| **Depends On** | Project 01 (gold layer), Project 06 (feature store) |
| **Feeds Into** | Standalone portfolio piece |

## Key Deliverables

- [ ] Snowflake Feature Store provides engineered features via Dynamic Tables
- [ ] Qlik AutoML consumes feature store for no-code model training
- [ ] Model explainability (SHAP-like feature importance in Qlik)
- [ ] Prediction writeback from Qlik to Snowflake
- [ ] Qlik dashboard showing model performance and predictions

## How This Fits in the 15-Project Plan

Bridges **Snowflake ML and Qlik ML** — shows that the same feature engineering (done properly in Snowflake) serves both Snowpark ML and Qlik AutoML. Demonstrates the "feature store as shared resource" pattern.
