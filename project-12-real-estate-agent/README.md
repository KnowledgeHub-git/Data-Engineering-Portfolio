# Project 12 — Real Estate Investment Advisor Agent

Conversational AI agent that evaluates real estate investment opportunities by combining housing prices, demographics, crime data, weather risk, and disaster history.

---

## Status: Planned

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | AI Agent Developer |
| **Snowflake Features** | Cortex Agent, Multi-tool, Multi-geography Comparison, Risk Assessment |
| **Source Data** | US_REAL_ESTATE, FHFA_HOUSE_PRICE, ACS, FBI_CRIME, NWS_WEATHER, FEMA_DISASTER |
| **Depends On** | Project 01 (geography), Project 02 (weather), Project 06 (climate risk) |
| **Feeds Into** | Standalone portfolio piece |

## Key Deliverables

- [ ] Agent tools: analyze_market, assess_risk, compare_locations
- [ ] Multi-geography comparison (e.g., "Tampa vs Austin for rental investment")
- [ ] Risk factor integration: crime + natural disaster + weather + price trends
- [ ] Conversational multi-turn flow with follow-up refinements
- [ ] Streamlit UI with side-by-side city comparison

## How This Fits in the 15-Project Plan

The most **consumer-facing agent** — demonstrates how to build something end-users would actually use. Combines the most data sources (6+) and shows the agent can synthesize across disparate domains into actionable advice.
