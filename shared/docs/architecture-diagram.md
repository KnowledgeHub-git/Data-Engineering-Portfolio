# Architecture Overview

## Data Flow Across All 15 Projects

The portfolio follows a layered architecture where each phase builds on the previous:

```
SOURCE LAYER (Read-Only)
========================
SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE (370 views)
  - Financial: STOCK_PRICE, FX_RATES, SEC filings, OPENFIGI, PERMID
  - Economic: FEDERAL_RESERVE, BLS, US_TREASURY, WORLD_BANK, IMF, OECD
  - Weather: NWS, NOAA, AWC METAR/TAF
  - Company: COMPANY_INDEX, TRANSCRIPTS, RELATIONSHIPS
  - Health: NPPES providers, Medicare taxonomy
  - Geographic: GEOGRAPHY_INDEX, US_ADDRESSES, ACS demographics
  - Academic: OPENALEX (works, authors, institutions)
  - Patent: USPTO patents, text, contributors
  - Government: USA_SPENDING, IRS, FEMA, FBI_CRIME
  - Energy: EIA, EPA, NRC nuclear reactors

SNOWFLAKE_SAMPLE_DATA.TPCH_SF1 (8 tables)
  - CUSTOMER, ORDERS, LINEITEM, PART, PARTSUPP, SUPPLIER, NATION, REGION


DATA ENGINEERING LAYER (Projects 1-3)
=====================================
Database: PORTFOLIO_DATA_MESH (Project 1)
  Schema: BRONZE   → Raw Dynamic Tables mirroring source
  Schema: SILVER   → Cleaned, typed, enriched
  Schema: GOLD     → Star schema (facts + dimensions)

Database: PORTFOLIO_WEATHER (Project 2)
  Schema: STAGING  → Streaming ingestion
  Schema: ANALYTICS → Aggregated weather metrics

Database: PORTFOLIO_DATA_VAULT (Project 3)
  Schema: RAW_VAULT → Hubs, Links, Satellites
  Schema: BIZ_VAULT → Business Vault + PIT tables


ML LAYER (Projects 4-6)
========================
Database: PORTFOLIO_ML
  Schema: FEATURES      → Feature Store tables
  Schema: MODELS        → Model Registry artifacts
  Schema: PREDICTIONS   → Output tables from ML models
  Schema: EXPERIMENTS   → Experiment tracking


GenAI LAYER (Projects 7-9)
===========================
Database: PORTFOLIO_GENAI
  Schema: SEARCH_SERVICES  → Cortex Search indexes
  Schema: SEMANTIC_MODELS  → Cortex Analyst YAML definitions
  Schema: CHUNKS           → Chunked documents for RAG
  Schema: OUTPUTS          → Generated summaries, extractions


AGENTS LAYER (Projects 10-12)
=============================
Database: PORTFOLIO_AGENTS
  Schema: TOOLS      → Agent tool definitions
  Schema: SESSIONS   → Agent conversation logs
  Schema: CONFIGS    → Agent configurations


BI LAYER (Projects 13-15)
=========================
Qlik Sense connects to GOLD schemas via ODBC Direct Query
  - Star schema maps naturally to associative model
  - Dimension tables = Qlik dimensions
  - Fact tables = Qlik measures
```

## Cross-Project Data Lineage

```
SNOWFLAKE_PUBLIC_DATA_FREE
    |
    +---> Project 1 (BRONZE) ---> Project 1 (SILVER) ---> Project 1 (GOLD)
    |         |                                               |
    |         +---> Project 2 (Weather BRONZE)                +---> Project 13 (Qlik)
    |         |                                               +---> Project 4 (ML features)
    |         +---> Project 3 (Raw Vault)                     +---> Project 7 (Analyst)
    |                   |                                     +---> Project 10 (Agent tool)
    |                   +---> Project 3 (Biz Vault)
    |                             |
    |                             +---> Project 14 (Qlik AutoML)
    |
    +---> Project 7 (Transcript chunks) ---> Cortex Search ---> Project 10 (Agent)
    +---> Project 8 (Patent text)       ---> AI_EXTRACT   ---> Structured output
    +---> Project 9 (SEC filings)       ---> RAG pipeline ---> Project 10 (Agent)
```
