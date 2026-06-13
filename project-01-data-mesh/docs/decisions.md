# Architecture Decision Records — Project 01

## ADR-001: Dynamic Tables over Materialized Views

**Status:** Accepted

**Context:** Need to materialize data from public data views with automatic refresh.

**Decision:** Use Dynamic Tables with `TARGET_LAG = '1 day'`.

**Rationale:**
- Dynamic Tables auto-refresh based on target lag without manual task scheduling
- Built-in lineage tracking visible in Snowsight
- Declarative — define the query, Snowflake handles refresh scheduling
- Supports incremental refresh for large datasets
- Materialized Views can't reference other databases

**Consequences:** Requires a warehouse running (credit consumption during refresh).

---

## ADR-002: EAV to Wide Pivot in Silver (Stock Prices)

**Status:** Accepted

**Context:** Source stock data is Entity-Attribute-Value (one row per ticker+variable+date). Analytics queries need OHLCV in columns.

**Decision:** Pivot to wide format in the Silver layer using conditional aggregation.

**Rationale:**
- One row per ticker-date is the natural grain for time-series analysis
- Eliminates repeated self-joins in downstream queries
- Plays well with Qlik associative model (one dimension per column)
- ML frameworks (Snowpark, pandas) expect wide tabular data

**Consequences:** Slightly more storage in silver, but dramatically simpler gold queries.

---

## ADR-003: Star Schema in Gold (not Data Vault)

**Status:** Accepted

**Context:** Gold layer needs to serve both BI dashboards and ML pipelines.

**Decision:** Star schema with explicit fact and dimension tables.

**Rationale:**
- Universal pattern understood by all BI tools (Qlik, Tableau, PowerBI)
- Qlik associative model maps 1:1 to star schema joins
- Cortex Analyst semantic models work best with clear fact/dimension separation
- Simpler than Data Vault for this scope (Data Vault is Project 3)

**Consequences:** Less flexible for ad-hoc exploration than Data Vault, but optimized for known analytical patterns.

---

## ADR-004: Technical Indicators Computed in Gold

**Status:** Accepted

**Context:** Moving averages, volatility, and daily returns are needed by ML (Project 4), Agents (Project 10), and dashboards (Project 13).

**Decision:** Compute indicators as window functions in the gold fact table.

**Rationale:**
- Single source of truth — all consumers get the same calculation
- Dynamic Tables auto-refresh these on new data
- Avoids redundant computation across projects
- Window functions on ordered data are efficient in Snowflake

**Consequences:** Gold fact table is wider but self-contained. Downstream projects don't need to recompute.
