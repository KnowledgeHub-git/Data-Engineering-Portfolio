# Project 02 — Real-Time Weather Pipeline

Real-time weather data ingestion pipeline using Snowpipe Streaming patterns, Dynamic Tables with tight target lag, and Snowflake Alerts for threshold-based monitoring.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Engineer |
| **Snowflake Features** | Snowpipe Streaming, Dynamic Tables (tight lag), Alerts, Materialized Views |
| **Source Data** | NWS_WEATHER_TIMESERIES, AWC_METAR_TIMESERIES, NWS_WEATHER_ALERT_EVENTS, GEOGRAPHY_INDEX |
| **Depends On** | Project 01 (geography dimension) |
| **Feeds Into** | Project 06 (Climate Risk), Project 12 (Real Estate Agent) |

## Key Deliverables

- [ ] Snowpipe Streaming ingestion pattern (simulated via PIT tables as changelog)
- [ ] Dynamic Tables with sub-hour target lag for near-real-time aggregation
- [ ] Materialized views for latest-observation snapshots
- [ ] Snowflake ALERT objects triggered on extreme weather thresholds
- [ ] Qlik real-time weather monitoring dashboard

## How This Fits in the 15-Project Plan

This project demonstrates **streaming ingestion** and **operational alerting** — critical data engineering skills complementary to the batch patterns in Project 01. The weather data feeds into the Climate Risk ML model (Project 06) and the Real Estate Investment Agent (Project 12) for risk assessment.
