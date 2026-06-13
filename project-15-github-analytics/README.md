# Project 15 — GitHub Developer Analytics

Qlik Sense dashboard analyzing open-source project momentum using GitHub event data, with company-to-repo mapping for competitive intelligence.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | BI Developer |
| **Snowflake Features** | Qlik Associative Model, Time Series, Semi-structured JSON |
| **Source Data** | GITHUB_EVENTS, GITHUB_REPOS, GITHUB_STARS, COMPANY_DOMAIN_RELATIONSHIPS |
| **Depends On** | None (standalone, but benefits from Project 01 company dim) |
| **Feeds Into** | Standalone portfolio piece |

## Key Deliverables

- [ ] Analyze OSS project momentum (star velocity, event frequency, contributor growth)
- [ ] Map repos to companies using COMPANY_DOMAIN_RELATIONSHIPS
- [ ] Qlik associative exploration: company → OSS activity → contributor patterns
- [ ] Time-series of community engagement
- [ ] Semi-structured JSON parsing in Snowflake for GitHub event payloads

## How This Fits in the 15-Project Plan

Demonstrates working with **semi-structured data** (JSON events) and building **competitive intelligence** dashboards. A lighter project that rounds out the portfolio with a tech-industry-relevant use case.
