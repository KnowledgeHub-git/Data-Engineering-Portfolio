# Qlik Cloud Connection — Financial Document QA

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `FINANCIAL_DOC_QA` |
| Schema | `RESULTS` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Load Script

```qlik
LIB CONNECT TO 'Snowflake_FinDocQA';

// QA Results
SAMPLE_QA_RESULTS:
LOAD
    QUESTION_ID,
    SESSION_ID,
    QUESTION,
    LEFT(ANSWER, 2000) AS ANSWER,
    SOURCE_COMPANY_1,
    SOURCE_SECTION_1,
    SOURCE_PERIOD_1,
    SOURCE_COMPANY_2,
    SOURCE_SECTION_2,
    SOURCE_PERIOD_2,
    CREATED_AT
;
SQL SELECT * FROM FINANCIAL_DOC_QA.RESULTS.SAMPLE_QA_RESULTS;

// Conversation Log
CONVERSATION_LOG:
LOAD
    SESSION_ID,
    TURN_NUMBER,
    ROLE,
    LEFT(MESSAGE, 2000) AS MESSAGE,
    CREATED_AT
;
SQL SELECT SESSION_ID, TURN_NUMBER, ROLE, MESSAGE, CREATED_AT
    FROM FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG;

// Corpus metadata (no full text)
FILING_METADATA:
LOAD
    CIK,
    COMPANY_NAME,
    FORM_TYPE,
    ITEM_TITLE,
    FISCAL_PERIOD,
    FISCAL_YEAR,
    FILED_DATE,
    CHUNK_LEN
;
SQL SELECT CIK, COMPANY_NAME, FORM_TYPE, ITEM_TITLE, FISCAL_PERIOD, FISCAL_YEAR, FILED_DATE, CHUNK_LEN
    FROM FINANCIAL_DOC_QA.STAGING.FILING_CHUNKS;
```

## Associative Model

- `SESSION_ID` links SAMPLE_QA_RESULTS ↔ CONVERSATION_LOG
- `COMPANY_NAME` links QA sources ↔ FILING_METADATA (via SOURCE_COMPANY_1/2)
- `ITEM_TITLE` links sections across tables

## Suggested Measures

- Count of questions per session (multi-turn depth)
- Most-queried companies
- Section distribution in search results
- Answer length by question type
