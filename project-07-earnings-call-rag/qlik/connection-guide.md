# Qlik Connection Guide — Project 07 Earnings Call RAG

## Connection Settings

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Database** | `EARNINGS_RAG` |
| **Schema** | `RESULTS` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |

## Load Script

```qvs
LIB CONNECT TO 'Snowflake_EarningsRAG';

// RAG Q&A Results
QA_RESULTS:
LOAD *;
SQL SELECT QUESTION, ANSWER, SOURCE_TICKER_1, SOURCE_EVENT_1,
    SOURCE_TICKER_2, SOURCE_EVENT_2, SOURCE_CHUNK_PREVIEW
FROM EARNINGS_RAG.RESULTS.SAMPLE_QA_RESULTS;

// Chunk statistics (for dashboard context)
CHUNK_STATS:
LOAD *;
SQL SELECT TICKER, COUNT(*) AS CHUNK_COUNT,
    MIN(EVENT_DATE) AS EARLIEST_CALL, MAX(EVENT_DATE) AS LATEST_CALL
FROM EARNINGS_RAG.STAGING.TRANSCRIPT_CHUNKS
GROUP BY TICKER
ORDER BY CHUNK_COUNT DESC
LIMIT 50;
```

## Measures

```
// Total chunks indexed
Sum(CHUNK_COUNT)

// Companies covered
Count(DISTINCT TICKER)

// Questions answered
Count(QUESTION)
```
