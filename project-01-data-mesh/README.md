# Project 01 — Multi-Domain Data Mesh

Modern lakehouse architecture implementing a Bronze/Silver/Gold medallion pattern using Snowflake Dynamic Tables, with a star schema optimized for BI consumption (Qlik Sense) and downstream ML/AI workloads.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Engineer |
| **Snowflake Features** | Dynamic Tables, Streams, Tasks, Star Schema, Time Travel |
| **Source Data** | SNOWFLAKE_PUBLIC_DATA_FREE (Company, Stock, Economic, Geography, Calendar) |
| **Database** | `PORTFOLIO_DATA_MESH` |
| **Warehouse** | `PORTFOLIO_WH` (XS) |
| **Downstream Projects** | 4 (Stock Forecasting), 7 (Earnings Call RAG), 10 (Market Research Agent), 13 (Qlik KPI Suite) |

---

## Architecture

```
SNOWFLAKE_PUBLIC_DATA_FREE (370 views)
           |
           v
┌─────────────────────────────────────────────────────────────┐
│  PORTFOLIO_DATA_MESH                                         │
│                                                              │
│  BRONZE (Dynamic Tables, TARGET_LAG = '1 day')              │
│  ├── bronze_stock_prices                                     │
│  ├── bronze_company_index                                    │
│  ├── bronze_federal_reserve                                  │
│  └── bronze_geography                                        │
│           |                                                  │
│           v                                                  │
│  SILVER (Dynamic Tables — cleaned, typed, enriched)          │
│  ├── silver_stock_daily        (OHLCV pivot)                │
│  ├── silver_company_enriched   (flattened arrays)           │
│  ├── silver_economic_indicators (categorized)               │
│  └── silver_geography_dim      (hierarchical levels)        │
│           |                                                  │
│           v                                                  │
│  GOLD (Star Schema — facts + dimensions)                     │
│  ├── gold_fact_stock_prices    (daily + technical indicators)│
│  ├── gold_dim_company          (company master)             │
│  ├── gold_dim_calendar         (date spine)                 │
│  ├── gold_dim_geography        (hierarchical geography)     │
│  └── gold_wide_market_summary  (denormalized dashboard tbl) │
│           |                                                  │
│           v                                                  │
│  ORCHESTRATION                                               │
│  ├── stream_bronze_stock_prices                             │
│  ├── stream_bronze_company_index                            │
│  ├── stream_bronze_federal_reserve                          │
│  ├── task_check_data_freshness                              │
│  └── task_monitor_stock_gaps                                │
└─────────────────────────────────────────────────────────────┘
           |                              |
           v                              v
   Project 4, 7, 10 (ML/AI)       Project 13 (Qlik)
```

---

## Prerequisites

1. Snowflake account with `SNOWFLAKE_PUBLIC_DATA_FREE` database accessible
2. `ACCOUNTADMIN` role (or equivalent with `CREATE DATABASE`, `CREATE WAREHOUSE`)
3. Any warehouse size (XS works fine)

---

## How to Run

Execute scripts in numbered order:

```
sql/00_setup/01_create_database.sql     -- Create database + warehouse
sql/00_setup/02_create_schemas.sql      -- Create BRONZE, SILVER, GOLD, ORCHESTRATION schemas
sql/01_bronze/bronze_stock_prices.sql   -- Bronze Dynamic Tables (run all 4)
sql/01_bronze/bronze_company_index.sql
sql/01_bronze/bronze_federal_reserve.sql
sql/01_bronze/bronze_geography.sql
sql/02_silver/silver_stock_daily.sql    -- Silver Dynamic Tables (run all 4)
sql/02_silver/silver_company_enriched.sql
sql/02_silver/silver_economic_indicators.sql
sql/02_silver/silver_geography_dim.sql
sql/03_gold/gold_fact_stock_prices.sql  -- Gold dimension + fact tables (run all 5)
sql/03_gold/gold_dim_company.sql
sql/03_gold/gold_dim_calendar.sql
sql/03_gold/gold_dim_geography.sql
sql/03_gold/gold_wide_market_summary.sql
sql/04_orchestration/streams.sql        -- Streams for CDC
sql/04_orchestration/tasks.sql          -- Monitoring tasks
sql/05_tests/test_row_counts.sql        -- Validate data flows
sql/05_tests/test_data_freshness.sql    -- Validate refresh health
```

Dynamic Tables will begin refreshing automatically after creation. Initial refresh may take a few minutes depending on data volume.

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Dynamic Tables over views** | Auto-refresh, built-in lineage tracking, production-ready pattern |
| **TARGET_LAG = '1 day'** | Source data updates daily; no need for sub-hour refresh |
| **OHLCV pivot in Silver** | Eliminates EAV pattern; one row per ticker-date is natural for analytics |
| **Technical indicators in Gold** | Moving averages and volatility computed at the fact level; reusable by ML and BI |
| **Separate market summary table** | Pre-aggregated for dashboard performance; avoids expensive window functions at query time |
| **Star schema in Gold** | Universal pattern that maps directly to Qlik associative model and Cortex Analyst |

---

## Outputs

After running all scripts, you will have:

- **13 Dynamic Tables** across 3 schemas (auto-refreshing daily)
- **3 Streams** capturing CDC events
- **2 Tasks** for pipeline monitoring
- A clean **star schema** ready for:
  - Qlik Sense Direct Query (Project 13)
  - Cortex ML feature engineering (Project 4)
  - Cortex Analyst semantic model (Project 7, 10)

---

## Downstream Dependencies

```
This Project (01)
    |
    +---> Project 04 (Stock Forecasting)
    |     Uses: gold_fact_stock_prices for time-series forecasting
    |
    +---> Project 07 (Earnings Call RAG)
    |     Uses: gold_dim_company for entity resolution in RAG
    |
    +---> Project 10 (Market Research Agent)
    |     Uses: gold layer as SQL tool data source for the agent
    |
    +---> Project 13 (Qlik KPI Suite)
          Uses: entire gold layer via ODBC Direct Query
```

---

## File Structure

```
project-01-data-mesh/
├── README.md                      (this file)
├── sql/
│   ├── 00_setup/
│   │   ├── 01_create_database.sql
│   │   └── 02_create_schemas.sql
│   ├── 01_bronze/
│   │   ├── bronze_stock_prices.sql
│   │   ├── bronze_company_index.sql
│   │   ├── bronze_federal_reserve.sql
│   │   └── bronze_geography.sql
│   ├── 02_silver/
│   │   ├── silver_stock_daily.sql
│   │   ├── silver_company_enriched.sql
│   │   ├── silver_economic_indicators.sql
│   │   └── silver_geography_dim.sql
│   ├── 03_gold/
│   │   ├── gold_fact_stock_prices.sql
│   │   ├── gold_dim_company.sql
│   │   ├── gold_dim_calendar.sql
│   │   ├── gold_dim_geography.sql
│   │   └── gold_wide_market_summary.sql
│   ├── 04_orchestration/
│   │   ├── streams.sql
│   │   └── tasks.sql
│   └── 05_tests/
│       ├── test_row_counts.sql
│       └── test_data_freshness.sql
├── docs/
│   ├── data-model.md
│   └── decisions.md
└── qlik/
    └── connection-guide.md
```
