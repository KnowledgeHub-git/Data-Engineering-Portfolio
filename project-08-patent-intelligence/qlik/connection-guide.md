# Qlik Connection Guide — Project 08 Patent Intelligence

## Connection Settings

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Database** | `PATENT_AI` |
| **Schema** | `RESULTS` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |

## Load Script

```qvs
LIB CONNECT TO 'Snowflake_PatentAI';

AI_PATENTS:
LOAD *;
SQL SELECT PATENT_ID, INVENTION_TITLE, APPLICATION_DATE,
    CPC_SECTION_DESCRIPTION, CPC_CLASS_DESCRIPTION, NUMBER_OF_CLAIMS,
    AI_CATEGORY, AI_SUMMARY
FROM PATENT_AI.RESULTS.AI_ENRICHED_PATENTS;
```

## Measures

```
// Patents by AI category
Count({<AI_CATEGORY={'AI/ML'}>} PATENT_ID)

// Average claims
Avg(NUMBER_OF_CLAIMS)
```
