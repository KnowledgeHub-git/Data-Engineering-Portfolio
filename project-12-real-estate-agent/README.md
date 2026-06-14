# Project 12 — Real Estate Investment Advisor Agent

AI agent that evaluates real estate investment opportunities by combining house price indices, mortgage rates, disaster risk data, and investment fundamentals.

---

## Status: Complete

## Overview

| Attribute | Value |
|-----------|-------|
| **Target Persona** | Property Investor, RE Analyst |
| **Snowflake Features** | Cortex Agent, Cortex Search, Custom UDFs, Freddie Mac HPI, FEMA Data |
| **Tools** | 5 (1 Search, 3 Custom UDFs, 1 Chart) |
| **Knowledge Base** | 72 curated entries across 8 RE investment categories |
| **Data Sources** | Freddie Mac (HPI + rates), FEMA (disasters), Geography Index |
| **Streamlit** | Deployed to SiS as RE_ADVISOR_CHAT |

## Architecture

```
                    REAL_ESTATE.AGENT.RE_ADVISOR_AGENT
                         (orchestration: auto)
                                  |
        +-------------+-------------+-------------+-------------+
        |             |             |             |             |
  investment     get_state_hpi   get_mortgage   get_disaster   data_to
  _knowledge     (UDF)           _rates (UDF)   _risk (UDF)    _chart
  (Search)            |              |              |
        |        FREDDIE_MAC    FREDDIE_MAC    FEMA_DISASTER
  RE_KNOWLEDGE   _HOUSING       _HOUSING       _DECLARATION
  _BASE (72)     _TIMESERIES    _TIMESERIES    _AREAS_INDEX
```

## Tools

| Tool | Type | Source | Returns |
|------|------|--------|---------|
| `investment_knowledge` | Cortex Search | 72-entry knowledge base | RE fundamentals, metrics, strategies |
| `get_state_hpi` | UDF | Freddie Mac HPI | 12 months state-level price index |
| `get_mortgage_rates` | UDF | Freddie Mac | Current 30yr/15yr/ARM national rates |
| `get_disaster_risk` | UDF | FEMA declarations | Disaster count + recent events by state |
| `data_to_chart` | Built-in | N/A | Visualizations |

## Knowledge Base Categories

| Category | Entries | Topics |
|----------|---------|--------|
| Investment Fundamentals | 10 | Cap rate, NOI, 1% rule, IRR, DSCR, GRM |
| Market Analysis | 10 | Supply/demand, absorption, comps, emerging markets |
| Risk Factors | 10 | Flood, hurricane, earthquake, wildfire, insurance crisis |
| Mortgage Analysis | 10 | LTV, DTI, ARM vs fixed, refinancing, portfolio lending |
| Location Criteria | 10 | Jobs, schools, transit, crime, taxes, landlord laws |
| Property Types | 8 | SFR, multifamily, STR, REIT, commercial, fix-and-flip |
| Tax and Legal | 6 | 1031 exchange, depreciation, capital gains, LLC |
| Market Cycles | 8 | Recovery, expansion, hyper-supply, recession indicators |

## Usage

```sql
-- Via SQL:
SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('REAL_ESTATE.AGENT.RE_ADVISOR_AGENT',
  $${"messages":[{"role":"user","content":[{"type":"text","text":"Compare California and Texas for investment"}]}],"stream":false}$$);
```

Also available via:
- Streamlit app: `RE_ADVISOR_CHAT` in Snowsight
- Snowflake CoWork (agent appears automatically)

## Credit Usage

~0.6 credits (Search indexing + 1 test agent call + UDF compute).
