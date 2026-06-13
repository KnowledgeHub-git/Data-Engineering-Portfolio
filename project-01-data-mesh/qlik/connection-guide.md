# Qlik Connection Guide — Project 01 Data Mesh

## Connecting Qlik Cloud to Snowflake

### Connection Settings (Verified Working)

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Port** | `443` |
| **Database** | `SALES_DOMAIN` |
| **Schema** | `CURATED` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |
| **User** | `BIWARO` |
| **Auth** | Username + Password |

> Note: The data mesh uses 3 domain databases. The connection defaults to SALES_DOMAIN
> but the load script queries across all domains using fully-qualified names.

### Data Mesh Architecture

| Database | Schema | Tables |
|----------|--------|--------|
| `SALES_DOMAIN` | `CURATED` | COMPANY_DIRECTORY, STOCK_DAILY_OHLCV |
| `FINANCE_DOMAIN` | `CURATED` | CORPORATE_FINANCIALS, ECONOMIC_METRICS, INSTITUTION_DIRECTORY |
| `MARKETING_DOMAIN` | `CURATED` | DIGITAL_PRESENCE, INDUSTRY_PROFILES, INNOVATION_INDEX |

### Recommended Load Script

```qvs
// =============================================================
// Qlik Sense Load Script — Portfolio Data Mesh (Cross-Domain)
// Loads from CURATED layer across 3 domain databases
// Connection: Snowflake_Portfolio (COMPUTE_WH / ACCOUNTADMIN)
// =============================================================

LIB CONNECT TO 'Snowflake_Portfolio';

// =============================================================
// SALES DOMAIN
// =============================================================

// Company Directory (master dimension)
COMPANY_DIRECTORY:
LOAD *;
SQL SELECT
    COMPANY_ID,
    COMPANY_NAME,
    ENTITY_LEVEL,
    EIN,
    CIK,
    PERMID_COMPANY_ID,
    PRIMARY_TICKER,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME
FROM SALES_DOMAIN.CURATED.COMPANY_DIRECTORY;

// Stock OHLCV (main fact table)
STOCK_DAILY:
LOAD *;
SQL SELECT
    TICKER,
    ASSET_CLASS,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    "DATE" AS TRADE_DATE,
    OPEN_PRICE,
    HIGH_PRICE,
    LOW_PRICE,
    CLOSE_PRICE,
    VOLUME
FROM SALES_DOMAIN.CURATED.STOCK_DAILY_OHLCV
WHERE "DATE" >= '2020-01-01';

// =============================================================
// FINANCE DOMAIN
// =============================================================

// Corporate Financials (SEC filings)
CORPORATE_FINANCIALS:
LOAD *;
SQL SELECT
    CIK,
    ADSH,
    FORM_TYPE,
    METRIC_TAG,
    MEASURE_DESCRIPTION,
    UNIT,
    AMOUNT,
    PERIOD_START_DATE,
    PERIOD_END_DATE,
    COVERED_QTRS
FROM FINANCE_DOMAIN.CURATED.CORPORATE_FINANCIALS;

// Economic Metrics (Federal Reserve / macro data)
ECONOMIC_METRICS:
LOAD *;
SQL SELECT
    GEO_ID,
    VARIABLE,
    VARIABLE_NAME,
    "DATE" AS METRIC_DATE,
    VALUE,
    UNIT
FROM FINANCE_DOMAIN.CURATED.ECONOMIC_METRICS;

// Financial Institutions Directory
INSTITUTION_DIRECTORY:
LOAD *;
SQL SELECT
    ID_RSSD,
    NAME,
    CATEGORY,
    IS_ACTIVE,
    CITY,
    STATE_ABBREVIATION,
    ENTITY_TYPE,
    FEDERAL_REGULATOR,
    CHARTER_TYPE,
    INSURER,
    NAICS_CODE
FROM FINANCE_DOMAIN.CURATED.INSTITUTION_DIRECTORY;

// =============================================================
// MARKETING DOMAIN
// =============================================================

// Industry Profiles (company classification)
INDUSTRY_PROFILES:
LOAD *;
SQL SELECT
    COMPANY_ID,
    COMPANY_NAME,
    INDUSTRY,
    SIC_DESCRIPTION,
    STATE,
    CITY,
    ENTITY_TYPE
FROM MARKETING_DOMAIN.CURATED.INDUSTRY_PROFILES;

// Digital Presence (company domains)
DIGITAL_PRESENCE:
LOAD *;
SQL SELECT
    COMPANY_ID,
    COMPANY_NAME,
    DOMAIN_ID,
    RELATIONSHIP_START_DATE,
    RELATIONSHIP_END_DATE,
    IS_ACTIVE
FROM MARKETING_DOMAIN.CURATED.DIGITAL_PRESENCE;

// Innovation Index (patents)
INNOVATION_INDEX:
LOAD *;
SQL SELECT
    PATENT_ID,
    INVENTION_TITLE,
    PATENT_STATUS,
    PATENT_TYPE,
    APPLICATION_DATE,
    DOCUMENT_PUBLICATION_DATE,
    NUMBER_OF_CLAIMS,
    CPC_SECTION_DESCRIPTION,
    CPC_CLASS_DESCRIPTION
FROM MARKETING_DOMAIN.CURATED.INNOVATION_INDEX;
```

### Associative Model — Key Links

| Qlik Table | Key Field | Links To |
|------------|-----------|----------|
| STOCK_DAILY | `TICKER` | COMPANY_DIRECTORY.`PRIMARY_TICKER` |
| CORPORATE_FINANCIALS | `CIK` | COMPANY_DIRECTORY.`CIK` |
| INDUSTRY_PROFILES | `COMPANY_ID` | COMPANY_DIRECTORY.`COMPANY_ID` |
| DIGITAL_PRESENCE | `COMPANY_ID` | COMPANY_DIRECTORY.`COMPANY_ID` |

### Suggested Qlik Measures

```
// Daily return %
(CLOSE_PRICE - OPEN_PRICE) / OPEN_PRICE

// Average daily volume
Avg(VOLUME)

// Total filings by company
Count(DISTINCT ADSH)

// Active patents
Count({<PATENT_STATUS={'Active'}>} PATENT_ID)

// Trading days loaded
Count(DISTINCT TRADE_DATE)
```

### Set Analysis Examples

```
// Filter stock data to 2024
{<TRADE_DATE={">='2024-01-01'"}>}

// Only US exchanges
{<PRIMARY_EXCHANGE_CODE={'XNYS','XNAS'}>}

// Quarterly SEC filings only
{<FORM_TYPE={'10-Q'}>}

// Active institutions only
{<IS_ACTIVE={1}>}
```
