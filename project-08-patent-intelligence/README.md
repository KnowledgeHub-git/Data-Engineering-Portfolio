# Project 08 — Patent Intelligence

AI-powered patent analysis using Cortex AI functions to extract, summarize, classify, and find similar patents across the USPTO corpus.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | AI_EXTRACT, AI_SUMMARIZE, AI_CLASSIFY, AI_EMBED, Vector Search |
| **Source Data** | USPTO_PATENT_INDEX, USPTO_PATENT_TEXT_ATTRIBUTES, OPENALEX_WORKS_INDEX, COMPANY_INDEX |
| **Depends On** | Project 01 (company dimension) |
| **Feeds Into** | Standalone portfolio piece (competitive intelligence) |

## Key Deliverables

- [ ] AI_EXTRACT: structured fields from patent text (claims, tech domains, inventors)
- [ ] AI_SUMMARIZE: executive-level patent digests
- [ ] AI_CLASSIFY: categorize patents by technology vertical
- [ ] Embedding + similarity search for related patent discovery
- [ ] Company-to-patent mapping for competitive intelligence

## How This Fits in the 15-Project Plan

Showcases the full suite of **Cortex AI functions** on unstructured text — a different pattern from the RAG approach in Project 07. Demonstrates extraction, classification, and embedding-based similarity in a single pipeline.
