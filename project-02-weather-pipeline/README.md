# Project 02 — Real-Time Weather Pipeline

Near-real-time weather data pipeline using Snowflake Dynamic Tables, ALERT objects, and Qlik monitoring dashboard. Demonstrates streaming-pattern ingestion from NWS/METAR marketplace data.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Engineer |
| **Snowflake Features** | Dynamic Tables (15-min lag), Alerts, Views, Marketplace Data |
| **Source Data** | NWS_WEATHER_TIMESERIES, AWC_METAR_TIMESERIES, NWS_WEATHER_ALERT_EVENTS |
| **Data Volume** | ~10M rows (POC cap) |
| **Depends On** | Snowflake Public Data Free (marketplace) |
| **Feeds Into** | Project 06 (Climate Risk), Project 12 (Real Estate Agent) |

## Architecture

```
SNOWFLAKE_PUBLIC_DATA_FREE (Marketplace)
    │
    ▼
WEATHER_DOMAIN.RAW (Time-windowed views)
    ├── WEATHER_OBSERVATIONS (10M rows, 7 key variables)
    ├── METAR_REPORTS (500K cap, airport weather)
    ├── WEATHER_ALERTS (90-day window, ~410K events)
    └── STATION_INDEX (73K stations with lat/lon)
    │
    ▼
WEATHER_DOMAIN.CURATED (Dynamic Tables)
    ├── LATEST_STATION_READINGS (15-min lag, pivoted wide)
    ├── HOURLY_AGGREGATES (1-hr lag, per station/variable)
    ├── DAILY_SUMMARIES (1-hr lag, derived from hourly)
    └── ACTIVE_ALERTS (15-min lag, geo-enriched)
    │
    ▼
WEATHER_DOMAIN.PRODUCTS (Alerts + Consumption)
    ├── ALERT_HISTORY (log of triggered threshold breaches)
    ├── EXTREME_TEMP_ALERT (fires on > 40C or < -30C)
    ├── HIGH_WIND_ALERT (fires on gust > 100 kph)
    └── SEVERE_ALERT_WATCHER (fires on Extreme NWS alerts)
```

## Key Deliverables

- [x] Time-windowed RAW views on marketplace data (zero storage cost)
- [x] 4 Dynamic Tables with 15-minute and 1-hour target lag
- [x] Pivoted wide-row station readings for dashboarding
- [x] 3 Snowflake ALERT objects with threshold monitoring
- [x] Alert history table logging all triggered events
- [x] Qlik Cloud load script and connection guide

## Reproducing This Project

### Prerequisites

- Snowflake account with `ACCOUNTADMIN` role
- `SNOWFLAKE_PUBLIC_DATA_FREE` database (free marketplace dataset)
- Qlik Cloud tenant with Snowflake connector

### Steps

```bash
# Run SQL files in order:
# 1. Infrastructure
snowsql -f sql/00_setup/01_create_database.sql

# 2. RAW layer views
snowsql -f sql/01_bronze/raw_views.sql

# 3. CURATED Dynamic Tables
snowsql -f sql/02_silver/curated_dynamic_tables.sql

# 4. PRODUCTS + Alerts
snowsql -f sql/03_gold/alerts_and_products.sql
```

### Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md) for connection settings and load script.

## Design Decisions

1. **Views for RAW layer**: Marketplace data updates automatically. Views avoid duplication while maintaining the domain pattern.
2. **10M row cap**: POC scope. Production would use the full 7.7B+ rows with larger warehouse.
3. **LIMIT on views**: Prevents runaway DT refreshes. In production, use time-based filters with CURRENT_TIMESTAMP().
4. **Alert history table**: Logs instead of email because notification integration requires separate admin setup.
5. **Hourly → Daily cascade**: Daily summaries derived from hourly (not raw) to reduce compute cost.

## Weather Variables Tracked

| Variable | Unit | Description |
|----------|------|-------------|
| temperature | Celsius | Air temperature |
| dew_point | Celsius | Dew point temperature |
| relative_humidity | Percent | Relative humidity |
| wind_speed | km/h | Sustained wind speed |
| wind_gust | km/h | Maximum wind gust |
| barometric_pressure | Pascal | Station pressure |
| visibility | Meters | Horizontal visibility |
