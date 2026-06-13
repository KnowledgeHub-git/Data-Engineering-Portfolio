# Project 03 — Economic Data Vault

Data Vault 2.0 architecture modeling economic entities from FEDERAL_RESERVE, BLS, US_TREASURY, and WORLD_BANK sources — demonstrating hubs, links, satellites, and vintage/revision tracking.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Data Engineer |
| **Snowflake Features** | Data Vault 2.0, PIT Tables, Business Vault, Hash Keys |
| **Source Data** | FINANCIAL_ECONOMIC_INDICATORS (vintage), BLS, FEDERAL_RESERVE, US_TREASURY, WORLD_BANK |
| **Depends On** | Project 01 (shared geography/calendar dimensions) |
| **Feeds Into** | Project 04 (Stock Forecasting), Project 10 (Market Agent), Project 14 (Qlik AutoML) |

## Key Deliverables

- [ ] Hub tables: Hub_Geography, Hub_Indicator, Hub_Source
- [ ] Link tables: Link_Indicator_Geography, Link_Indicator_Source
- [ ] Satellite tables with full audit history
- [ ] Vintage/revision tracking (how GDP revisions change over time)
- [ ] PIT (Point-in-Time) tables for as-of analytical queries
- [ ] Business Vault layer for analyst-friendly consumption

## How This Fits in the 15-Project Plan

Demonstrates **Data Vault 2.0** — the industry-standard pattern for building auditable, scalable data warehouses. Complements the star schema in Project 01 by showing when and why you'd choose Data Vault over dimensional modeling.
