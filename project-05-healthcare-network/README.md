# Project 05 — Healthcare Provider Network Analysis

Network analysis of US healthcare providers using NPPES data — clustering, healthcare desert detection, and deactivation risk classification via Cortex ML.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Scientist |
| **Snowflake Features** | Cortex ML CLASSIFICATION, Window Functions, ACS Demographics |
| **Source Data** | NPPES (9.6M providers), American Community Survey |
| **POC Scope** | 5M providers, 500-row scoring sample (credit-efficient) |
| **Feeds Into** | Standalone healthcare analytics portfolio piece |

## Architecture

```
NPPES_NPI_INDEX + PRACTITIONER_ATTRIBUTES + TAXONOMY + ADDRESSES
    │
    ▼
HEALTH_ML.STAGING
    ├── PROVIDER_PROFILES (5M, joined wide: specialty + geography + lifecycle)
    ├── STATE_PROVIDER_DENSITY (providers per 100K by state + specialty)
    ├── DEACTIVATION_FEATURES (ML feature matrix)
    └── CLASSIFICATION_TRAINING (10K balanced: 5K active + 5K deactivated)
    │
    ▼
HEALTH_ML.RESULTS
    ├── PROVIDER_CLUSTERS (5 segments: Metro, Rural, Academic, Suburban, Mixed)
    ├── HEALTHCARE_DESERTS (97 severe deserts across 39 states)
    └── DEACTIVATION_RISK_SCORES (classifier predictions)
```

## Key Findings

### Provider Clusters
| Cluster | Segments | Providers |
|---------|----------|-----------|
| Metro High-Density | 150 | 3.1M |
| Academic/Specialty Hub | 327 | 1.5M |
| Suburban Moderate | 477 | 409K |
| Mixed/Transitional | 329 | 13K |
| Rural Low-Density | 148 | 1.2K |

### Healthcare Deserts
- **97 severe desert** state-specialty combinations across **39 states**
- Deserts defined as < 50% of national median providers per 100K
- Mental health and primary care most affected

### Deactivation Risk
- Model trained on balanced 10K sample (Cortex ML CLASSIFICATION)
- Predicts which active providers are likely to deactivate

## Reproducing

```sql
-- All SQL in sql/healthcare_pipeline.sql
-- Run in order: database → staging → clustering → deserts → classifier
```

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md)
