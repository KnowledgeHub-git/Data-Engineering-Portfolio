# Project 15 — GitHub Developer Analytics

Star velocity and project momentum analysis for 30 top data/AI open-source repositories.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | BI Developer, OSS Analyst |
| **Snowflake Features** | Window functions, CTAS, Views, Streamlit-in-Snowflake |
| **Source Data** | GITHUB_STARS (68M rows), GITHUB_REPOS (591M rows) |
| **Curated Repos** | 30 top data/AI projects |
| **Data Range** | Jan 2024 — Jun 2026 (24,895 daily star records) |
| **Credit Cost** | ~0.3 credits (stars-only approach, skipped 3.5B events table) |
| **Streamlit** | Deployed as `GITHUB_DASHBOARD` |

## Architecture

```
SNOWFLAKE_PUBLIC_DATA_FREE
  GITHUB_REPOS (591M) ──filter 30──> CURATED_REPOS (30 repos)
  GITHUB_STARS (68M)  ──join──────> STAR_VELOCITY (24,895 rows)
                                          |
                                    REPO_RANKINGS (view)
                                          |
                              ┌────────────┴────────────┐
                         Streamlit              Qlik Cloud
                      (2-tab dashboard)        (load script)
```

## Repos Tracked

LangChain, Hugging Face Transformers, CrewAI, Supabase, AutoGen, PyTorch, FastAPI, TensorFlow, Tailwind CSS, Qdrant, dbt-core, Streamlit, Polars, DuckDB, Gradio, LlamaIndex, Airflow, MLflow, Ray, Pandas, pgvector, Chroma, Snowflake CLI, Next.js, OpenAI Python, and more.

## Key Metrics

| Metric | Description |
|--------|-------------|
| STARS_ADDED | Daily new stars per repo |
| CUMULATIVE_STARS | Running total since first star |
| STARS_7D_AVG | 7-day moving average (smoothed trend) |
| STARS_LAST_30D | Stars added in last 30 days |
| GROWTH_ACCELERATION | This week vs avg of prior 4 weeks (>1 = accelerating) |

## Streamlit Dashboard

Two tabs:
1. **Project Rankings** — Bar chart of 30-day stars, full rankings table with acceleration
2. **Star Velocity** — Multi-repo line chart comparing weekly star growth over time

## Credit Efficiency

Saved ~1.8 credits by skipping the 3.5B-row GITHUB_EVENTS table. The stars-only approach still delivers project momentum, popularity comparisons, and growth acceleration — the most actionable OSS analytics metrics.
