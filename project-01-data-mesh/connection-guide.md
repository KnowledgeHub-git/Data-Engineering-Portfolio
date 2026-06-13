# Qlik Cloud Connection Guide — Project 01 Data Mesh

## Overview

This guide connects Qlik Cloud to the Data Mesh PRODUCTS layer using **Direct Query** — Qlik queries Snowflake live without importing data. This preserves governance (masking policies enforce at query time) and ensures data is always fresh.

```
┌──────────────┐         ┌──────────────────────────────────┐
│  Qlik Cloud  │ ──SQL──►│  Snowflake (PRODUCTS schemas)    │
│  Direct Query│         │  Masking policies active          │
│  Live data   │         │  RBAC enforced per role           │
└──────────────┘         └──────────────────────────────────┘
```

## Prerequisites

- Qlik Cloud tenant: `https://s3a4yzntpv4dc47.de.qlikcloud.com`
- Snowflake account: `PYMWAGP-LGB07431` (AWS US West 2)
- A Snowflake user with access to PRODUCTS schemas (any READER role or above)

## Step 1: Create a Snowflake Connection in Qlik Cloud

1. Open Qlik Cloud → **Spaces** → select your space (e.g., `Default_Data_Space`)
2. Click **Add new** → **Data connection** → **Snowflake**
3. Fill in the connection details:

| Field | Value |
|-------|-------|
| Connection name | `Snowflake_DataMesh_Products` |
| Account | `PYMWAGP-LGB07431` |
| Database | `SALES_DOMAIN` (or any domain — you'll query cross-domain) |
| Warehouse | `GOVERNANCE_WH` (or domain-specific: `SALES_WH`, `FINANCE_WH`, `MARKETING_WH`) |
| Schema | `PRODUCTS` |
| Authentication | Username/Password or Key Pair |
| Username | Your Snowflake user (e.g., `biwaro`) |
| Role | `MESH_ADMIN` (sees all domains) or a specific domain READER |

4. Click **Test connection** → should show "Connection successful"
5. Click **Create**

### Role Selection Guide

| Qlik Use Case | Recommended Snowflake Role | Access |
|---------------|---------------------------|--------|
| Full mesh visibility (all domains) | `MESH_ADMIN` | All PRODUCTS + governance |
| Sales dashboards only | `SALES_READER` | SALES_DOMAIN.PRODUCTS only |
| Finance reporting only | `FINANCE_READER` | FINANCE_DOMAIN.PRODUCTS only |
| Marketing analytics only | `MARKETING_READER` | MARKETING_DOMAIN.PRODUCTS only |

## Step 2: Create a Qlik App with Direct Query

1. Go to **Analytics** → **Create new** → **Analytics app**
2. Name it: `Data Mesh Analytics`
3. Click **Add data** → **Direct Query**
4. Select the `Snowflake_DataMesh_Products` connection
5. In the SQL editor, use one of the queries below to load data

### Direct Query SQL — Sales Domain

```sql
SELECT * FROM SALES_DOMAIN.PRODUCTS.STOCK_PERFORMANCE
```

### Direct Query SQL — Finance Domain

```sql
SELECT * FROM FINANCE_DOMAIN.PRODUCTS.ECONOMIC_DASHBOARD
```

### Direct Query SQL — Marketing Domain

```sql
SELECT * FROM MARKETING_DOMAIN.PRODUCTS.INDUSTRY_SEGMENTATION
WHERE INDUSTRY IS NOT NULL
```

### Cross-Domain Query (requires MESH_ADMIN or OWNER role)

```sql
-- Stock performance with company industry context
SELECT 
  sp.TICKER,
  sp.DATE,
  sp.CLOSE_PRICE,
  sp.DAILY_RETURN_PCT,
  sp.VOLUME,
  mi.INDUSTRY,
  mi.STATE
FROM SALES_DOMAIN.PRODUCTS.STOCK_PERFORMANCE sp
LEFT JOIN MARKETING_DOMAIN.PRODUCTS.INDUSTRY_SEGMENTATION mi
  ON sp.TICKER = mi.COMPANY_NAME  -- approximate join for demo
WHERE sp.CLOSE_PRICE IS NOT NULL
```

## Step 3: Build Visualizations

With Direct Query active, create sheets in your Qlik app:

### Sheet 1: Market Overview
- **KPI**: Average Close Price, Total Volume
- **Bar chart**: Volume by Exchange
- **Line chart**: Price over time by Ticker

### Sheet 2: Economic Indicators
- **KPI**: Latest CPI value
- **Table**: All indicators with date and value
- **Filter pane**: By VARIABLE_NAME, UNIT

### Sheet 3: Company Landscape
- **Pie chart**: Companies by Industry
- **Map**: Companies by State
- **Table**: Company profiles with domain count

## Step 4: Governance Verification

Because Qlik uses Direct Query, **Snowflake masking policies are enforced live**:

```
If Qlik connects as SALES_READER:
  → EIN column shows ***MASKED***
  → All other non-PII data is visible

If Qlik connects as SALES_OWNER:
  → EIN column shows real values
  → Full access to all SALES_DOMAIN.PRODUCTS
```

Test this by:
1. Creating two separate Qlik connections (one as READER, one as OWNER)
2. Loading the same table in both
3. Comparing the EIN column — READER sees masked values

## Step 5: Schedule Refresh (Optional)

Since this is Direct Query, data is always live. However, you can configure:

- **Reload schedule**: Not needed (queries hit Snowflake live)
- **Cache**: Qlik may cache results — set cache TTL in app settings if freshness is critical
- **Alerts**: Set Qlik alerts on specific KPIs that query Snowflake in real-time

## Connection Architecture

```
Qlik Cloud (DE region)
    │
    │ HTTPS/TLS (port 443)
    │
    ▼
Snowflake (AWS US West 2)
    │
    ├── Role: MESH_ADMIN / SALES_READER / etc.
    ├── Warehouse: GOVERNANCE_WH (auto-suspend 60s)
    ├── Database: *_DOMAIN
    └── Schema: PRODUCTS
         ├── Secure Views (masking enforced)
         └── Semantic Views (for reference)
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| "Object does not exist" | Wrong database/schema in connection | Set Database to the domain you need |
| Empty results | READER role can't see other domains | Use MESH_ADMIN or switch to correct domain |
| `***MASKED***` in data | Masking policy active for your role | Connect as OWNER or CONTRIBUTOR role |
| Slow queries | Warehouse suspended | Warehouse auto-resumes; first query takes ~2s |
| "Insufficient privileges" | Role doesn't have SELECT on view | Grant USAGE + SELECT on the specific PRODUCTS schema |

## MCP Plugin (Advanced)

For programmatic Qlik management from Cortex Code, the Qlik MCP plugin is configured at:

```
~/.snowflake/cortex/plugins/qlik-cloud/
```

Tools available: `qlik_get_apps`, `qlik_get_app_sheets`, `qlik_get_chart_data`, `qlik_list_spaces`, `qlik_reload_app`

OAuth2 M2M client: `019ec0dd0250cead89ea39c7a1b067df`
Tenant: `https://s3a4yzntpv4dc47.de.qlikcloud.com`

---

## Summary

| What | How |
|------|-----|
| Connection type | Direct Query (live, no import) |
| Authentication | Username/Password or Key Pair to Snowflake |
| Governance | Masking policies enforced at query time |
| Freshness | Always live — no reload needed |
| Performance | XS warehouse, auto-suspend 60s, auto-resume |
| Cross-domain | Use MESH_ADMIN role for full access |
