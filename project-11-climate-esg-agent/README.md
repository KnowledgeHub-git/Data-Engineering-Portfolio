# Project 11 — Climate & ESG Compliance Agent

AI agent that assesses ESG compliance by combining regulatory framework knowledge, country emissions data, and corporate SEC climate disclosures.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | ESG/Compliance Officer, Sustainability Analyst |
| **Snowflake Features** | Cortex Agent, Cortex Search, Custom UDFs, Multi-tool Orchestration |
| **Tools** | 5 (2 Search, 2 Custom UDFs, 1 Chart) |
| **Knowledge Base** | 88 curated entries across 11 ESG frameworks |
| **Depends On** | Project 06 (Climate Risk), Project 09 (SEC filings) |

## Architecture

```
                    CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT
                         (orchestration: auto)
                                  |
        +-------------+-------------+-------------+-------------+
        |             |             |             |             |
  regulations    filings_climate  get_country   get_emissions   data_to
  _search        _search          _emissions    _trend          _chart
  (Search)       (Search)         (UDF)         (UDF)           (built-in)
        |             |             |             |
  ESG_KNOWLEDGE  FILING_SEARCH   FEATURE_STORE  EMISSIONS_
  _BASE (88)     _SVC (28K)      _CLIMATE       _TRENDS
```

## Tools

| Tool | Type | Purpose |
|------|------|---------|
| `regulations_search` | Cortex Search | ESG frameworks: Paris, CSRD, TCFD, GHG Protocol, SBTi, EU Taxonomy, SEC Rule, GRI |
| `filings_climate_search` | Cortex Search | Company SEC climate disclosures (reuses Project 09 index) |
| `get_country_emissions` | Custom UDF | Country emissions profile with sector breakdown and risk tier |
| `get_emissions_trend` | Custom UDF | YoY emissions trajectory for top 50 emitters |
| `data_to_chart` | Built-in | Visualizations from emissions/regulatory data |

## ESG Knowledge Base Coverage

| Framework | Entries | Key Content |
|-----------|---------|-------------|
| Paris Agreement | 10 | NDC, 1.5C pathway, carbon budgets, Article 6, transparency |
| EU CSRD | 12 | Double materiality, ESRS E1, timeline, value chain, penalties |
| TCFD | 10 | 4 pillars, scenario analysis, physical/transition risks |
| GHG Protocol | 10 | Scope 1/2/3, organizational boundary, calculation methods |
| SBTi | 10 | Near-term, net-zero, FLAG, sector pathways, validation |
| EU Taxonomy | 5 | 6 objectives, technical screening, transitional activities |
| SEC Climate Rule | 5 | Scope 1/2, attestation, financial statement effects |
| GRI Standards | 4 | GRI 305/302, materiality, reporting principles |
| Sector Thresholds | 12 | Power, steel, cement, aviation, auto, buildings, O&G, shipping |
| Climate Risk | 6 | Physical/transition risk, carbon pricing, stranded assets |
| Compliance Checklist | 4 | Minimum requirements, greenwashing indicators, investor expectations |

## Usage

```sql
-- Regulatory question:
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT',
  $${"messages":[{"role":"user","content":[{"type":"text","text":"What are the TCFD governance requirements?"}]}],"stream":false}$$);

-- Compliance assessment (multi-tool):
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT',
  $${"messages":[{"role":"user","content":[{"type":"text","text":"Is China on track for Paris targets?"}]}],"stream":false}$$);
```

## Differentiators from Project 10

| Aspect | Project 10 (Market Research) | Project 11 (Climate ESG) |
|--------|------------------------------|--------------------------|
| Domain | Financial markets | Regulatory compliance |
| Knowledge base | None (uses existing search) | 88 curated ESG framework entries |
| Accuracy | Informational | Audit-grade with citations |
| Use case | "What's happening?" | "Is X compliant with Y?" |
| Data tools | Macro indicators | Country emissions + risk tiers |

## Credit Usage

~0.7 credits (Search indexing 88 rows + 2 test agent calls + warehouse compute).
