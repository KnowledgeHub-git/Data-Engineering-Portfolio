# Project 09 — Financial Document QA

Multi-turn conversational interface over SEC filings (10-K, 10-Q, 8-K) using document parsing, Cortex Search, and Cortex Complete.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | AI_PARSE_DOCUMENT, Cortex Search, Cortex Complete, Multi-turn Chat |
| **Source Data** | SEC_REPORT_TEXT_ATTRIBUTES, SEC_CORPORATE_REPORT_TEXT_ATTRIBUTES, SEC_8K_ATTRIBUTES |
| **Depends On** | Project 01 (company dimension) |
| **Feeds Into** | Project 10 (Market Research Agent) |

## Key Deliverables

- [ ] Document AI pipeline: parse SEC filings with AI_PARSE_DOCUMENT
- [ ] Cortex Search over 10-K/10-Q/8-K text sections
- [ ] Multi-turn conversational interface with context window management
- [ ] Evaluation: hallucination rate measurement, verified query repository
- [ ] Streamlit chat UI with document citations

## How This Fits in the 15-Project Plan

Deepens the **document understanding** capability beyond Project 07 (which focuses on transcripts). Adds document parsing and multi-turn conversation — both essential for production-grade AI systems. Feeds directly into the Market Research Agent.
