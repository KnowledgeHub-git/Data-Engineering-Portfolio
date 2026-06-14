# From Raw Data to Autonomous AI Agents: A 15-Project Snowflake Portfolio

What does it take to build a modern data platform from scratch? Not slides. Not theory. Working systems.

This repository contains 15 interconnected projects that progressively transform raw marketplace data into production-grade data products, machine learning models, generative AI pipelines, and autonomous AI agents — all on Snowflake, all deployed, all working.

---

## The Story

It starts simple: messy financial, weather, and economic data from 370+ free Snowflake marketplace views. By the end, you have AI agents that autonomously research markets, assess ESG compliance, and advise on real estate investments — powered by the data engineering, ML, and GenAI layers built in earlier projects.

**Phase 1** lays the data foundation. A multi-domain data mesh with proper governance. A real-time weather pipeline with Dynamic Tables and automated alerts. An economic data vault using Data Vault 2.0 methodology.

**Phase 2** adds intelligence. Cortex ML models forecast stock prices and detect anomalies. Classification models predict healthcare provider attrition and score country climate risk. A feature store emerges as a shared resource.

**Phase 3** makes data conversational. RAG pipelines answer questions about earnings calls using 432K transcript chunks. SEC filing analysis enables multi-turn Q&A over 28K document sections from 49 companies. Patent text gets classified and summarized by AI.

**Phase 4** ties it all together with autonomous agents. A Market Research Agent orchestrates 7 tools to synthesize structured analytics, earnings transcripts, SEC filings, and macro-economic data. A Climate ESG Agent assesses regulatory compliance against 88 curated framework entries. A Real Estate Advisor pulls live mortgage rates, house price indices, and FEMA disaster data to compare investment opportunities.

**Phase 5** connects everything to business users through Qlik dashboards, AutoML experiments, and GitHub analytics — proving the data products work beyond the engineering layer.

---

## What's Inside

| Phase | # | Project | What It Proves |
|-------|---|---------|----------------|
| Data Engineering | 01 | [Multi-Domain Data Mesh](project-01-data-mesh/) | Domain ownership, Dynamic Tables, governance at scale |
| | 02 | [Real-Time Weather Pipeline](project-02-weather-pipeline/) | Streaming ingestion, alerts, operational data products |
| | 03 | [Economic Data Vault](project-03-economic-data-vault/) | Data Vault 2.0, temporal modeling, auditability |
| Machine Learning | 04 | [Stock Price Forecasting](project-04-stock-forecasting/) | Cortex ML FORECAST + ANOMALY_DETECTION, multi-series |
| | 05 | [Healthcare Network Analysis](project-05-healthcare-network/) | Clustering, classification, gap analysis |
| | 06 | [Climate Risk Scoring](project-06-climate-risk-scoring/) | Feature store, risk classification, model registry |
| Generative AI | 07 | [Earnings Call RAG](project-07-earnings-call-rag/) | Cortex Search (432K chunks), retrieval-augmented generation |
| | 08 | [Patent Intelligence](project-08-patent-intelligence/) | AI classification + summarization at scale |
| | 09 | [Financial Document QA](project-09-financial-doc-qa/) | Multi-turn RAG, session memory, SEC filing analysis |
| AI Agents | 10 | [Market Research Agent](project-10-market-research-agent/) | 7-tool Cortex Agent, multi-source synthesis |
| | 11 | [Climate ESG Agent](project-11-climate-esg-agent/) | Compliance assessment, curated knowledge base |
| | 12 | [Real Estate Advisor](project-12-real-estate-agent/) | Live data UDFs, FEMA/HPI/mortgage integration |
| BI & Analytics | 13 | [Qlik KPI Suite](project-13-qlik-kpi-suite/) | Executive dashboards, consumption views, Set Analysis |
| | 14 | [Qlik AutoML Pipeline](project-14-qlik-automl/) | Feature store to no-code ML, model comparison |
| | 15 | [GitHub Developer Analytics](project-15-github-analytics/) | Star velocity, OSS project momentum, 30 repos |

---

## Architecture

```
                    SNOWFLAKE PUBLIC DATA FREE (370+ views)
         Financial | Economic | Weather | Health | SEC | GitHub
                                   |
            ┌──────────────────────┼──────────────────────┐
            v                      v                      v
   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
   │  PHASE 1        │   │  PHASE 2        │   │  PHASE 3        │
   │  Data Eng       │   │  Machine        │   │  Generative     │
   │                 │   │  Learning       │   │  AI             │
   │  Data Mesh      │   │  Forecasting    │   │  RAG Pipelines  │
   │  Weather DTs    │   │  Classification │   │  Cortex Search  │
   │  Data Vault 2.0 │   │  Feature Store  │   │  Multi-turn QA  │
   └────────┬────────┘   └────────┬────────┘   └────────┬────────┘
            │                     │                      │
            └─────────────────────┼──────────────────────┘
                                  v
                    ┌──────────────────────────┐
                    │  PHASE 4: AI AGENTS      │
                    │                          │
                    │  Market Research (7 tools)│
                    │  Climate ESG (5 tools)    │
                    │  Real Estate (5 tools)    │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              v                                     v
   ┌──────────────────────┐              ┌──────────────────────┐
   │  Streamlit in SF     │              │  Qlik Cloud          │
   │  8 deployed apps     │              │  12 apps + 3 AutoML  │
   │  Chat UIs + KPIs     │              │  Dashboards + ML     │
   └──────────────────────┘              └──────────────────────┘
```

---

## The Numbers

| Metric | Count |
|--------|-------|
| Snowflake databases created | 18 |
| Cortex Agents deployed | 4 |
| Cortex Search services (indexed chunks) | 4 (485K+ chunks) |
| Cortex ML models trained | 4 |
| Streamlit apps deployed to SiS | 8 |
| Qlik Cloud apps | 12 |
| Qlik AutoML experiments | 3 |
| Total rows processed | 3.5B+ (GitHub events alone) |
| Companies analyzed | 49 (SEC filings), 10K+ (directory) |
| Countries covered | 194 (climate), 50 (emissions trends) |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Data Platform** | Snowflake (Dynamic Tables, Streams, Tasks, Data Vault, Star Schema) |
| **ML** | Snowflake Cortex ML (Forecast, Anomaly Detection, Classification) |
| **Generative AI** | Cortex Search, Cortex Complete (mistral-large2), Cortex AI Functions |
| **AI Agents** | Cortex Agents (CREATE AGENT, DATA_AGENT_RUN, multi-tool orchestration) |
| **Apps** | Streamlit-in-Snowflake (warehouse runtime) |
| **BI** | Qlik Cloud (Direct Query, AutoML, associative model, Set Analysis) |
| **Source Data** | Snowflake Public Data Free (370+ marketplace views, zero cost) |

---

## How Each Project Builds on the Last

```
Project 01 (Gold Layer) ──────> Projects 04, 07, 10, 13
Project 03 (Economic Vault) ──> Projects 10 (macro context UDF), 14 (feature store)
Project 06 (Climate Risk) ────> Projects 11 (emissions tools), 14 (AutoML features)
Project 07 (Earnings Search) ─> Projects 10, 11 (Cortex Search tool in agents)
Project 09 (SEC Filings) ─────> Projects 10, 11 (filings_search tool in agents)
Projects 04-06 (ML outputs) ──> Project 14 (unified feature store for Qlik AutoML)
All gold layers ──────────────> Project 13 (KPI Suite consumption views)
```

---

## Running This Yourself

### Prerequisites

1. Snowflake account with `SNOWFLAKE_PUBLIC_DATA_FREE` database available
2. `COMPUTE_WH` warehouse (X-Small is sufficient)
3. `ACCOUNTADMIN` role (or equivalent CREATE privileges)
4. (Optional) Qlik Cloud account for Projects 13-15
5. No external APIs, no Python installs, no infrastructure setup needed

### Execution Order

```
Phase 1 (Foundation):  01 → 02 → 03
Phase 2 (ML):          04 → 05 → 06
Phase 3 (GenAI):       07 → 08 → 09
Phase 4 (Agents):      10 → 11 → 12
Phase 5 (BI):          13 → 14 → 15
```

Each project folder contains:
- `sql/` — Complete DDL and DML (run in Snowflake)
- `streamlit/` — Streamlit app (deployed via PUT + CREATE STREAMLIT)
- `qlik/connection-guide.md` — Qlik load scripts and connection settings
- `README.md` — Architecture, deliverables, and usage examples

---

## Key Design Decisions

**Zero external dependencies.** Everything runs inside Snowflake. No AWS Lambda, no external APIs, no Python packages beyond what SiS provides. The marketplace data is free. The compute is minimal.

**Credit-efficient.** The entire portfolio was built within 200 EUR of Snowflake credits. Techniques used: LIMIT clauses on large tables, targeted company sets (49 for SEC filings, 30 for GitHub), feature truncation (30K chars max), and the stars-only approach for GitHub (skipping the 3.5B events table).

**Progressive complexity.** Each phase builds on the last. You can stop after Phase 1 and have a working data mesh. Stop after Phase 3 and have a full GenAI stack. The agents in Phase 4 combine everything into something genuinely useful.

**Production patterns, not toys.** Multi-turn conversation memory. Session tracking. Citation provenance. FEMA disaster data for real risk assessment. Actual SEC filings, not synthetic data.

---

## Author

**Mohamad Bouzi** — Data Engineer & AI Developer specializing in Snowflake, Cortex AI, and modern data platforms.

Built entirely with Snowflake Cortex Code as the development environment.

---

## License

This portfolio is for educational and demonstration purposes. Data sourced from Snowflake Public Data Free (marketplace) under Snowflake's terms of use.
