# Project 07 — Earnings Call RAG

Retrieval-Augmented Generation pipeline over company earnings call transcripts using Cortex Search and Cortex Complete, with a Streamlit chat interface.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | Cortex Search, Cortex Complete, Cortex Analyst, Streamlit-in-Snowflake |
| **Source Data** | COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES, COMPANY_INDEX, SEC_CORPORATE_REPORT_TEXT_ATTRIBUTES |
| **Depends On** | Project 01 (company dimension for entity resolution) |
| **Feeds Into** | Project 10 (Market Research Agent uses this as a tool) |

## Key Deliverables

- [ ] Cortex Search Service over chunked earnings call transcripts
- [ ] RAG pipeline: question → retrieve chunks → generate answer via Cortex Complete
- [ ] Cortex Analyst semantic model over financial metrics
- [ ] Streamlit-in-Snowflake chat UI
- [ ] Evaluation framework: answer quality scoring

## How This Fits in the 15-Project Plan

First **Generative AI** project — demonstrates RAG end-to-end. The Search service and Analyst model become reusable tools that the Market Research Agent (Project 10) orchestrates autonomously.
