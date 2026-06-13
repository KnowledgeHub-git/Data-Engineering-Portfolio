# Snowflake Portfolio: Modern Data Engineering, ML, GenAI & AI Agents

A comprehensive portfolio of 15 interconnected projects demonstrating end-to-end data platform engineering on Snowflake — from lakehouse architecture through machine learning, generative AI, and autonomous AI agents, with Qlik Sense integration for business intelligence.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Data Platform** | Snowflake (Dynamic Tables, Streams, Tasks, Time Travel, Data Sharing) |
| **Data Engineering** | SQL, Data Vault 2.0, Star Schema, Medallion Architecture |
| **ML & Data Science** | Snowflake Cortex ML (Forecast, Anomaly Detection, Classification), Snowpark Python |
| **Generative AI** | Cortex AI (Complete, Search, Analyst, Extract, Summarize, Classify) |
| **AI Agents** | Cortex Agents (multi-tool orchestration, RAG, semantic models) |
| **App Layer** | Streamlit-in-Snowflake |
| **BI & Visualization** | Qlik Sense (Direct Query, load scripts, associative model) |
| **Source Data** | Snowflake Public Data Free (370 views), TPC-H sample data |

---

## Project Map

| # | Project | Persona | Snowflake Features | Status |
|---|---------|---------|-------------------|--------|
| 01 | [Multi-Domain Data Mesh](project-01-data-mesh/) | Data Engineer | Dynamic Tables, Streams, Tasks, Star Schema | In Progress |
| 02 | [Real-Time Weather Pipeline](project-02-weather-pipeline/) | Data Engineer | Snowpipe Streaming, Dynamic Tables, Alerts | Planned |
| 03 | [Economic Data Vault](project-03-economic-data-vault/) | Data Engineer | Data Vault 2.0, PIT Tables, Business Vault | Planned |
| 04 | [Stock Price Forecasting](project-04-stock-forecasting/) | Data Scientist | Cortex ML Forecast, Anomaly Detection, Snowpark UDFs | Planned |
| 05 | [Healthcare Network Analysis](project-05-healthcare-network/) | Data Scientist | Snowpark ML, Clustering, Classification | Planned |
| 06 | [Climate Risk Scoring](project-06-climate-risk-scoring/) | Data Scientist | Cortex Classify, Feature Store | Planned |
| 07 | [Earnings Call RAG](project-07-earnings-call-rag/) | AI Developer | Cortex Search, Cortex Complete, Streamlit | Planned |
| 08 | [Patent Intelligence](project-08-patent-intelligence/) | AI Developer | AI_EXTRACT, AI_SUMMARIZE, AI_CLASSIFY, Embeddings | Planned |
| 09 | [Financial Document QA](project-09-financial-doc-qa/) | AI Developer | AI_PARSE_DOCUMENT, Cortex Search, Multi-turn Chat | Planned |
| 10 | [Market Research Agent](project-10-market-research-agent/) | Agent Developer | Cortex Agent, Multi-tool, Analyst + Search | Planned |
| 11 | [Climate ESG Agent](project-11-climate-esg-agent/) | Agent Developer | Cortex Agent, Regulation Search, Emissions Query | Planned |
| 12 | [Real Estate Advisor Agent](project-12-real-estate-agent/) | Agent Developer | Cortex Agent, Multi-geography, Risk Assessment | Planned |
| 13 | [Qlik KPI Suite](project-13-qlik-kpi-suite/) | BI Developer | Qlik Direct Query, Set Analysis, Gold Layer | Planned |
| 14 | [Qlik AutoML Pipeline](project-14-qlik-automl/) | BI + ML | Qlik AutoML, Feature Store Consumption, Writeback | Planned |
| 15 | [GitHub Developer Analytics](project-15-github-analytics/) | BI Developer | Qlik Associative Model, Time Series, GitHub Events | Planned |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│              SNOWFLAKE PUBLIC DATA FREE (370 views)                      │
│  Financial | Economic | Weather | Health | Academic | Government        │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │
                ┌──────────────────┼──────────────────┐
                v                  v                  v
     ┌──────────────────┐ ┌────────────────┐ ┌───────────────────┐
     │  DATA ENG LAYER  │ │   ML LAYER     │ │   GenAI LAYER     │
     │  Projects 1-3    │ │  Projects 4-6  │ │  Projects 7-9     │
     │  Dynamic Tables  │ │  Cortex ML     │ │  Cortex Search    │
     │  Streams/Tasks   │ │  Snowpark ML   │ │  Cortex Complete  │
     │  Data Vault      │ │  Feature Store │ │  Cortex Analyst   │
     └────────┬─────────┘ └───────┬────────┘ └────────┬──────────┘
              │                    │                   │
              └────────────────────┼───────────────────┘
                                   v
                      ┌────────────────────────┐
                      │   AI AGENTS LAYER      │
                      │   Projects 10-12       │
                      │   Cortex Agents        │
                      │   Multi-tool Reasoning │
                      └───────────┬────────────┘
                                  │
               ┌──────────────────┼──────────────────┐
               v                                     v
    ┌──────────────────────┐              ┌──────────────────┐
    │  Streamlit in SF     │              │   Qlik Sense     │
    │  Agent Chat UIs      │              │   Projects 13-15 │
    │  Internal Tools      │              │   Dashboards     │
    └──────────────────────┘              └──────────────────┘
```

---

## Dependency Graph

Projects build on each other:

- **Project 1** (Data Mesh) feeds → Projects 4, 7, 10, 13
- **Project 2** (Weather) feeds → Projects 6, 12
- **Project 3** (Data Vault) feeds → Projects 4, 10, 14
- **Projects 4-6** (ML) feed → Projects 10-12 (Agents use ML outputs)
- **Projects 7-9** (GenAI) feed → Projects 10-12 (Agents use Search/RAG tools)
- **Gold layers from 1-3** feed → Projects 13-15 (Qlik consumes gold)

---

## How to Use This Repo

### Prerequisites

1. Snowflake account with `SNOWFLAKE_PUBLIC_DATA_FREE` and `SNOWFLAKE_SAMPLE_DATA` databases available
2. A warehouse (XS is sufficient for most projects)
3. `ACCOUNTADMIN` or a role with `CREATE DATABASE` privileges
4. (Optional) Qlik Sense Desktop or Qlik Cloud for Projects 13-15
5. (Optional) Python 3.10+ for Snowpark projects

### Execution Order

```
Phase 1: Foundation     → Project 1, then 2, then 3
Phase 2: ML            → Project 4, then 5, then 6
Phase 3: GenAI         → Project 7, then 8, then 9
Phase 4: Agents        → Project 10, then 11, then 12
Phase 5: Qlik          → Project 13, then 14, then 15
```

You can skip ahead within each phase (e.g., jump to Project 7 without completing 2-3) since each project documents its own prerequisites. But the numbered order within each phase provides the smoothest experience.

### Running a Project

Each project folder contains:
- `README.md` — Full explanation of what, why, how, and downstream connections
- `sql/` — Numbered SQL scripts to run in order
- `docs/` — Architecture decisions and data model documentation
- `qlik/` or `streamlit/` — UI layer artifacts where applicable

---

## Qlik Integration

Projects 13-15 are dedicated Qlik projects, but most data engineering projects (1-3) include a `qlik/` folder with connection guides. The pattern:

1. Snowflake gold-layer tables provide clean, dimensional data
2. Qlik connects via the Snowflake ODBC connector (Direct Query or data load)
3. Set Analysis in Qlik leverages the star schema structure
4. Qlik AutoML (Project 14) reads from the Snowflake Feature Store

---

## Author

**Mohamad Bouzi** — Modern Data Engineer, AI Developer, Snowflake + Qlik Specialist

---

## License

This portfolio is for educational and demonstration purposes.
