# Project 08 — Patent Intelligence

AI-powered patent analysis using Cortex COMPLETE for classification and summarization of USPTO patents.

---

## Status: Complete (POC)

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Developer |
| **Snowflake Features** | Cortex COMPLETE (classification, summarization), CPC taxonomy |
| **Source Data** | USPTO_PATENT_INDEX (17M patents, POC: 2000 staged, 50 AI-enriched) |
| **Credit Usage** | ~100 LLM calls (50 patents x 2 functions) |

## Architecture

```
USPTO_PATENT_INDEX (17M patents, marketplace)
    │ Filter: 2000 recent patents with text (2023+)
    ▼
PATENT_AI.STAGING.PATENT_CORPUS (2000 rows, truncated text)
    │ AI functions on 50 patents
    ▼
PATENT_AI.RESULTS.AI_ENRICHED_PATENTS (50 rows)
    ├── AI_CATEGORY: Technology vertical classification
    └── AI_SUMMARY: One-sentence patent digest
```

## AI Functions Demonstrated

| Function | Purpose | Output |
|----------|---------|--------|
| COMPLETE (classify) | Categorize patent into tech vertical | AI/ML, Biotech, Telecom, etc. |
| COMPLETE (summarize) | One-sentence executive summary | ~30 word digest |

## Sample Results

| Patent | AI Category | Summary |
|--------|-------------|---------|
| Quality Testing of Communications | Telecom | Method for testing conference call endpoint quality |
| Pepper Hybrid SVPS0953 | Biotech | New pepper hybrid and parent lines |
| Ballasted Telecom Mounts | Telecom | Mounts using ballast for stability |
| Gadolinium Complex | Biotech | Complex with chelating ligand for MRI contrast |

## Qlik Integration

See [qlik/connection-guide.md](qlik/connection-guide.md)
