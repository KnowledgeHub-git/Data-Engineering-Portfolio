# Qlik Cloud Connection — Market Research Agent

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `MARKET_RESEARCH` |
| Schema | `RESULTS` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Notes

The Market Research Agent is primarily an interactive tool (via Snowflake CoWork or REST API). Qlik integration is limited to monitoring agent usage if a results/logging table is added in the future.

The agent's underlying data sources are already available via other project connections:
- Stock data: Project 01 (SALES_DOMAIN)
- Economic data: Project 03 (ECON_VAULT)
- Earnings transcripts: Project 07 (EARNINGS_RAG)
- SEC filings: Project 09 (FINANCIAL_DOC_QA)
