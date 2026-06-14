# Qlik Cloud Connection — Climate ESG Agent

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `CLIMATE_ESG` |
| Schema | `STAGING` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Load Script

```qlik
LIB CONNECT TO 'Snowflake_ClimateESG';

// ESG Knowledge Base
ESG_KNOWLEDGE_BASE:
LOAD
    CHUNK_ID,
    FRAMEWORK,
    SECTION,
    CONTENT,
    SOURCE_REF
;
SQL SELECT * FROM CLIMATE_ESG.STAGING.ESG_KNOWLEDGE_BASE;
```

## Notes

The Climate ESG Agent is primarily an interactive tool (via Snowflake CoWork or REST API). The Qlik connection provides access to the ESG knowledge base for dashboard visualization of framework coverage.

Underlying emissions data is available via Project 06 (CLIMATE_RISK database).
