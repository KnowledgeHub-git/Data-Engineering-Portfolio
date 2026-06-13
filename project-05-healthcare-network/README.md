# Project 05 — Healthcare Provider Network Analysis

Network analysis and clustering of US healthcare providers using NPPES data, identifying underserved areas and predicting provider deactivation risk.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Snowpark ML, Clustering, Classification, Graph Analytics |
| **Source Data** | NPPES_NPI_INDEX, NPPES_PROVIDER_ADDRESSES, NPPES_NUCC_TAXONOMY, GEOGRAPHY_INDEX, ACS |
| **Depends On** | Project 01 (geography dimension) |
| **Feeds Into** | Standalone portfolio piece |

## Key Deliverables

- [ ] Provider clustering by specialty and geography (K-Means via Snowpark)
- [ ] Healthcare desert detection (underserved areas: ACS demographics vs provider density)
- [ ] Graph analytics on referral patterns
- [ ] Classification model predicting provider deactivation risk
- [ ] Spatial analysis with H3 geospatial functions

## How This Fits in the 15-Project Plan

Demonstrates **domain-specific ML** on healthcare data — a high-value industry use case. Shows ability to combine multiple public datasets for actionable insights that matter to real organizations.
