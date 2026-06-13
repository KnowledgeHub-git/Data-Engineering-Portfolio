# Project 06 — Climate Risk Scoring

Composite climate risk scoring model per geography using emissions, weather extremes, and economic dependency data, with a Snowflake Feature Store for reuse.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Cortex CLASSIFY, Feature Store, Snowpark ML |
| **Source Data** | CLIMATE_WATCH, OUR_WORLD_IN_DATA, EPA_CAM, COMPANY_CHARACTERISTICS, GEOGRAPHY_INDEX |
| **Depends On** | Project 01 (geography), Project 02 (weather data) |
| **Feeds Into** | Project 11 (Climate ESG Agent) |

## Key Deliverables

- [ ] Composite climate risk score per geography (multi-factor model)
- [ ] Correlation analysis: emissions vs economic indicators
- [ ] Cortex CLASSIFY to bucket regions into risk tiers
- [ ] Feature Store tables in Snowflake for cross-project reuse
- [ ] Time-series decomposition of emissions trends

## How This Fits in the 15-Project Plan

Creates the **Feature Store** pattern that other projects consume. The climate risk scores become a key input for the ESG Agent (Project 11), demonstrating how ML outputs compound into agent capabilities.
