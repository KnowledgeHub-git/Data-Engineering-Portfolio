# Qlik Cloud Connection — Real Estate Advisor Agent

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `REAL_ESTATE` |
| Schema | `STAGING` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Load Script

```qlik
LIB CONNECT TO 'Snowflake_RealEstate';

RE_KNOWLEDGE_BASE:
LOAD CHUNK_ID, CATEGORY, TOPIC, CONTENT;
SQL SELECT * FROM REAL_ESTATE.STAGING.RE_KNOWLEDGE_BASE;
```

## Notes

The Real Estate Advisor Agent is interactive (Snowflake CoWork / Streamlit / REST API). Underlying market data comes from Snowflake Public Data Free (Freddie Mac, FEMA) accessed via UDFs at query time.
