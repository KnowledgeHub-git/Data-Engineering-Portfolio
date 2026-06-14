# Project 07 — Earnings Call RAG

Retrieval-Augmented Generation pipeline over 5000 earnings call transcripts using Cortex Search for semantic retrieval and Cortex COMPLETE for answer generation.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | Cortex Search Service, Cortex COMPLETE (mistral-large2), VARIANT parsing |
| **Source Data** | COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES (5000 transcripts, 3224 tickers) |
| **Chunks Indexed** | 432K paragraphs |
| **Feeds Into** | Project 10 (Market Research Agent uses this as a retrieval tool) |

## Architecture

```
COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES (Marketplace, 364K total)
    │ Filter: 5000 transcripts, SPEAKERS_ANNOTATED, Earnings Call
    ▼
EARNINGS_RAG.STAGING.TRANSCRIPT_CHUNKS (432K chunks)
    │ Paragraph-level text with ticker, event, fiscal period
    ▼
EARNINGS_RAG.SEARCH.EARNINGS_SEARCH_SVC (Cortex Search)
    │ Semantic search over chunk text
    ▼
EARNINGS_RAG.RESULTS.SAMPLE_QA_RESULTS (4 demo Q&A pairs)
    │ Question → Search → COMPLETE → Answer with source attribution
```

## How RAG Works Here

1. **User asks a question** (e.g., "What are companies saying about AI?")
2. **Cortex Search** retrieves top-3 most relevant transcript chunks
3. **Cortex COMPLETE** synthesizes an answer grounded in those chunks
4. **Source attribution** shows which ticker + earnings call the info came from

## Sample Results

| Question | Source | Answer Preview |
|----------|--------|----------------|
| AI investment strategy | SoftBank Q1 2026 | Companies increasingly investing in AI with early investments paying off... |
| Cloud revenue growth | NICE Q4 2022 | Companies using specific YoY percentages to highlight cloud growth... |
| Supply chain challenges | FN Q4 2023 | Revenue headwinds from supply chain constraints ~$15M in Q4... |
| Capital expenditure plans | MHPC Q3 2024 | Evaluating prior year spend and allocating based on priorities... |

## Reproducing

```sql
-- Run: sql/earnings_rag_pipeline.sql
-- Requires: SNOWFLAKE_PUBLIC_DATA_FREE access, COMPUTE_WH
```

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md)
