# Project 03 — Economic Data Vault

Data Vault 2.0 architecture on Snowflake modeling economic indicators from 5 sources — demonstrating hubs, links, satellites, hash keys, and vintage/revision tracking.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Engineer |
| **Snowflake Features** | Data Vault 2.0, Dynamic Tables, Hash Keys (MD5), PIT Tables |
| **Source Data** | Federal Reserve, BLS Employment, US Treasury, World Bank, BEA Vintage |
| **Data Volume** | ~2M observations + 24K vintage records |
| **Feeds Into** | Project 04 (Stock Forecasting), Project 10 (Market Agent), Project 14 (Qlik AutoML) |

## Architecture

```
SNOWFLAKE_PUBLIC_DATA_FREE (Marketplace)
    │
    ▼
ECON_VAULT.STAGING (Hash key computation + row caps)
    ├── STG_FEDERAL_RESERVE (2M rows, financial accounts)
    ├── STG_BLS_EMPLOYMENT (1.5M rows, US labor)
    ├── STG_US_TREASURY (273K rows, yields/debt)
    ├── STG_WORLD_BANK (1M rows, 50 countries)
    └── STG_VINTAGE (24K rows, BEA revision data)
    │
    ▼
ECON_VAULT.RAW_VAULT (Data Vault 2.0)
    ├── HUB_INDICATOR (6.7K unique indicators)
    ├── HUB_GEOGRAPHY (50 geographies)
    ├── LINK_INDICATOR_GEOGRAPHY (73K relationships)
    ├── SAT_INDICATOR_DETAILS (metadata: name, unit, source)
    ├── SAT_OBSERVATION (2M time-series values)
    └── SAT_OBSERVATION_VINTAGE (24K revision-tracked values)
    │
    ▼
ECON_VAULT.BUSINESS_VAULT (Analyst Consumption)
    ├── PIT_INDICATOR_LATEST (latest value per indicator)
    ├── VW_ECONOMIC_DASHBOARD (pre-joined wide view)
    └── VW_REVISION_TRACKER (revision deltas with LAG)
```

## Data Vault 2.0 Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| **Hub** | Business key store — one row per indicator or geography |
| **Link** | Relationship between indicator and geography |
| **Satellite** | Context/history: metadata, observations, revisions |
| **Hash Key** | MD5 surrogate keys for joins (no sequences needed) |
| **Hash Diff** | Change detection in satellites |
| **PIT Table** | Point-in-time: latest value without scanning full history |
| **Vintage/Revision** | Same date+indicator, multiple RELEASE_DATEs showing revisions |

## Key Deliverables

- [x] 2 Hub tables (Indicator, Geography)
- [x] 1 Link table (Indicator-Geography relationship)
- [x] 3 Satellite tables (details, observations, vintage)
- [x] PIT table for latest values
- [x] Pre-joined Business Vault views for Qlik
- [x] Revision tracker showing how GDP/CPI numbers get revised over time

## Reproducing This Project

```bash
# Run SQL in order:
snowsql -f sql/00_setup/01_create_database.sql
snowsql -f sql/01_staging/staging_views.sql
snowsql -f sql/02_raw_vault/hubs_links_satellites.sql
snowsql -f sql/03_business_vault/pit_and_views.sql
```

## Why Data Vault vs Star Schema?

| Factor | Star Schema (Project 01) | Data Vault (Project 03) |
|--------|--------------------------|------------------------|
| **Best for** | Reporting, known queries | Integration, unknown sources |
| **Schema changes** | Requires remodeling | Add new sats/links without breaking |
| **Audit** | Overwrite history | Full history preserved |
| **Revisions** | Hard to track | Native via vintage satellite |
| **Load complexity** | Transform on load | Load first, transform later |
| **Query speed** | Fast (fewer joins) | Slower (more joins, use Business Vault) |

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md) for load script and measures.
