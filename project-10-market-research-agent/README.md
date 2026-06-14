# Project 10 — Market Research Agent

Autonomous AI agent that combines financial data querying, earnings transcript search, SEC filing analysis, and macro-economic context to answer complex market research questions.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Agent Developer |
| **Snowflake Features** | Cortex Agent, Multi-tool Orchestration, Cortex Analyst + Cortex Search + Custom UDF |
| **Tools** | 7 (3 Analyst, 2 Search, 1 Custom, 1 Chart) |
| **Source Data** | Sales/Finance/Marketing domains (Project 01), Earnings transcripts (Project 07), SEC filings (Project 09), Economic vault (Project 03) |
| **Depends On** | Projects 01, 03, 07, 09 |
| **Role** | Capstone of the AI track |

## Architecture

```
                    MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT
                         (orchestration: auto)
                                  |
        +-----------+------+------+------+------+-----------+
        |           |      |      |      |      |           |
  sales_analytics  finance  marketing  earnings  filings  get_macro  data_to_chart
  (Analyst)        (Analyst) (Analyst)  (Search)  (Search)  (UDF)     (built-in)
        |           |      |      |      |      |
  SALES_DOMAIN  FINANCE_  MARKETING_  EARNINGS_RAG  FINANCIAL_DOC_QA  ECON_VAULT
  .PRODUCTS     DOMAIN    DOMAIN      .SEARCH       .SEARCH           .BUSINESS_VAULT
  .SALES_       .PRODUCTS .PRODUCTS   .EARNINGS_    .FILING_          .PIT_INDICATOR_
  ANALYTICS     .FINANCE_ .MARKETING_ SEARCH_SVC    SEARCH_SVC        LATEST
                ANALYTICS ANALYTICS
```

## Tools

| Tool | Type | Source | Description |
|------|------|--------|-------------|
| `sales_analytics` | Cortex Analyst | SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS | Stock prices, trading volume, company directory |
| `finance_analytics` | Cortex Analyst | FINANCE_DOMAIN.PRODUCTS.FINANCE_ANALYTICS | Economic indicators, SEC financial metrics |
| `marketing_analytics` | Cortex Analyst | MARKETING_DOMAIN.PRODUCTS.MARKETING_ANALYTICS | Industry profiles, digital presence, patents |
| `earnings_search` | Cortex Search | EARNINGS_RAG.SEARCH.EARNINGS_SEARCH_SVC | 432K earnings transcript chunks |
| `filings_search` | Cortex Search | FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC | 28K SEC 10-K/10-Q filing chunks |
| `get_macro_context` | Custom UDF | ECON_VAULT (Data Vault joins) | World Bank + Fed Reserve macro indicators |
| `data_to_chart` | Built-in | N/A | Auto-generates Vega-Lite charts from data |

## Key Deliverables

- [x] Cortex Agent with 7 tools spanning structured + unstructured data
- [x] Multi-step reasoning (agent calls multiple tools per question)
- [x] Custom UDF tool joining Data Vault tables for macro context
- [x] Correct tool routing via orchestration instructions
- [x] Tested with SEC filings search and macro-economic queries

## Usage

```sql
-- Via SQL (non-streaming):
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text", "text": "What risks does NVIDIA disclose in their SEC filings?"}]}], "stream": false }$$
);

-- With auto-created thread for multi-turn:
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text", "text": "How has inflation affected consumer goods earnings guidance?"}]}], "stream": false }$$,
    TRUE
);
```

Also available via:
- Snowflake CoWork (agent appears automatically)
- Cortex Agents REST API (`POST /api/v2/databases/MARKET_RESEARCH/schemas/AGENT/agents/MARKET_RESEARCH_AGENT:run`)

## Sample Questions

| Question | Tools Used |
|----------|-----------|
| "What risks does NVIDIA disclose in their SEC filings?" | filings_search |
| "What are the current unemployment rates globally?" | get_macro_context + finance_analytics |
| "Compare Microsoft and Google's AI strategy" | earnings_search + filings_search |
| "Show NVIDIA's stock price trend" | sales_analytics + data_to_chart |
| "How has inflation impacted consumer goods guidance?" | get_macro_context + earnings_search |

## Credit Usage

~0.7 credits (agent creation is free; each query costs ~0.1-0.2 in orchestration + tool execution).
