# Project 09 — Financial Document QA

Multi-turn conversational RAG over SEC 10-K/10-Q filings using Cortex Search and Cortex Complete.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | Cortex Search, Cortex Complete (mistral-large2), Sliding Window Chunking, Multi-turn Stored Procedure |
| **Source Data** | SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES (pre-parsed filing sections) |
| **Companies** | 49 (Tech, Finance, Healthcare, Consumer, Industrial/Energy) |
| **Corpus** | 2,741 filing sections → 28,487 searchable chunks |
| **Feeds Into** | Project 10 (Market Research Agent) |

## Architecture

```
SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES (1.1M rows)
    │
    ├─ Filter: 49 companies, 7 section types, 10-K/10-Q only
    ▼
FINANCIAL_DOC_QA.STAGING.FILING_CORPUS (2,741 sections, truncated to 30K chars)
    │
    ├─ Sliding window: 1500 chars, 200-char overlap (step = 1300)
    ▼
FINANCIAL_DOC_QA.STAGING.FILING_CHUNKS (28,487 chunks)
    │
    ├─ Cortex Search (snowflake-arctic-embed-m-v1.5)
    ▼
FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC
    │
    ├─ ASK_FILING() stored procedure (search → context → COMPLETE)
    ▼
FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG / SAMPLE_QA_RESULTS
```

## Key Deliverables

- [x] Chunked corpus from 49 companies' 10-K/10-Q filings (7 section types)
- [x] Cortex Search service with company/section/fiscal-period attributes
- [x] Multi-turn conversational procedure with session memory (last 3 turns)
- [x] Optional company filter for targeted queries
- [x] Citation tracking (company + section + fiscal period) in all responses
- [x] 7 demo Q&A pairs across Apple, NVIDIA, Tesla, JPMorgan, Microsoft

## Usage

```sql
-- Single question
CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING(
    'What are Apple''s main risk factors?', NULL, 'APPLE');

-- Multi-turn (reuse session ID for conversation memory)
CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING(
    'What legal proceedings is Tesla facing?', 'my-session', 'TESLA');
CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING(
    'How do those relate to their risk disclosures?', 'my-session', 'TESLA');

-- Cross-company comparison
CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING(
    'Compare AI strategies of Microsoft and NVIDIA', NULL, NULL);
```

## Companies Included

| Sector | Companies |
|--------|-----------|
| Tech | Apple, Microsoft, NVIDIA, Alphabet, Amazon, Tesla, Meta, Cisco, Qualcomm, AMD, Intel |
| Finance | Goldman Sachs, JPMorgan Chase, Visa, American Express, Wells Fargo |
| Healthcare | Pfizer, Johnson & Johnson, AbbVie, Thermo Fisher, Boston Scientific |
| Consumer | Coca-Cola, Starbucks, PepsiCo, Home Depot, Costco, P&G, Altria, Hilton |
| Industrial | ExxonMobil, Chevron, Boeing, Ford, 3M, Illinois Tool Works, UPS, Merck |

## Differences from Project 07 (Earnings RAG)

| Aspect | Project 07 | Project 09 |
|--------|------------|------------|
| Source | Earnings call transcripts | SEC 10-K/10-Q filed sections |
| Structure | Flat paragraphs | Structured items (Risk Factors, MD&A, etc.) |
| Chunking | Pre-split by paragraph | Sliding window (1500 char, 200 overlap) |
| Interface | Single-turn | Multi-turn with session memory |
| Citations | Ticker + event | Company + Section + Fiscal period |
| Corpus | 432K chunks (transcript paragraphs) | 28K chunks (filing sections) |

## Credit Usage

~1.5 credits total (Cortex Search indexing + 7 demo COMPLETE calls + warehouse compute).
