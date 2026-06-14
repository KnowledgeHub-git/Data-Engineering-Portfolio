# Project 13 — Qlik KPI Suite

Executive KPI dashboard consuming the gold layer across Sales, Finance, and Marketing domains with pre-aggregated consumption views.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | BI Developer, Executive |
| **Snowflake Features** | Views, Dimensions, Star Schema, Streamlit-in-Snowflake |
| **Source Data** | Gold layer from Projects 01-03 (PRODUCTS schemas) |
| **Output** | 3 KPI views + 2 dimensions + Streamlit dashboard + Qlik load script |
| **Streamlit** | Deployed as `KPI_DASHBOARD` in Snowsight |

## Architecture

```
SALES_DOMAIN.PRODUCTS          FINANCE_DOMAIN.PRODUCTS        MARKETING_DOMAIN.PRODUCTS
  STOCK_PERFORMANCE              ECONOMIC_DASHBOARD              INDUSTRY_SEGMENTATION
  COMPANY_MASTER                 CORPORATE_KPI                   DIGITAL_FOOTPRINT
        |                              |                              |
        +--------- KPI_SUITE ---------+------------------------------+
                        |
        +---------------+---------------+
        |               |               |
  DIM_CALENDAR    DIM_COMPANY     (join layer)
        |               |               |
  V_MARKET_KPI   V_ECONOMY_KPI  V_CORPORATE_KPI
        |               |               |
        +-------+-------+-------+-------+
                |               |
         Qlik Cloud App   Streamlit Dashboard
```

## Objects Created

| Object | Type | Rows | Description |
|--------|------|------|-------------|
| `KPI_SUITE.DIMENSIONS.DIM_CALENDAR` | Table | 2,357 | Master calendar (2020-today) |
| `KPI_SUITE.DIMENSIONS.DIM_COMPANY` | View | 10,000 | Unified company dimension |
| `KPI_SUITE.VIEWS.V_MARKET_KPI` | View | 3,149 | Monthly stock aggregates by ticker |
| `KPI_SUITE.VIEWS.V_ECONOMY_KPI` | View | 2,062 | Key macro indicators (CPI, unemployment, wages) |
| `KPI_SUITE.VIEWS.V_CORPORATE_KPI` | View | 4,199 | SEC financials (revenue, assets, net income) |
| `KPI_SUITE.VIEWS.KPI_DASHBOARD` | Streamlit | — | 3-tab executive dashboard |

## Streamlit Dashboard Tabs

1. **Market Performance** — Top/worst performers, price trends, volume by ticker
2. **Economic Indicators** — CPI, unemployment, wages with time-series charts
3. **Corporate Financials** — Revenue/assets by company, quarterly trends

## Qlik Integration

Full load script with associative model in `qlik/connection-guide.md`:
- 5 tables (2 dimensions + 3 facts)
- Auto-linking via DATE, TICKER, COMPANY_NAME, CIK, INDUSTRY
- Set Analysis expressions for YoY, QoQ, latest-period comparisons
- Suggested 3-tab dashboard structure

## Credit Usage

~0.2 credits (view creation is free; Streamlit consumes compute only when accessed).
