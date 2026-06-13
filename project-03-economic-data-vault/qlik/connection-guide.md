# Qlik Connection Guide — Project 03 Economic Data Vault

## Connection Settings

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Port** | `443` |
| **Database** | `ECON_VAULT` |
| **Schema** | `BUSINESS_VAULT` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |
| **User** | `BIWARO` |
| **Auth** | Username + Password |

## Recommended Load Script

```qvs
// =============================================================
// Qlik Sense Load Script — Economic Data Vault
// Loads from ECON_VAULT.BUSINESS_VAULT (pre-joined views)
// =============================================================

LIB CONNECT TO 'Snowflake_EconVault';

// Economic Dashboard (main fact - pre-joined from vault)
ECONOMIC_DATA:
LOAD *;
SQL SELECT
    INDICATOR_CODE,
    INDICATOR_NAME,
    UNIT,
    DATA_SOURCE,
    GEO_ID,
    GEO_NAME,
    COUNTRY_CODE,
    OBSERVATION_DATE,
    VALUE
FROM ECON_VAULT.BUSINESS_VAULT.VW_ECONOMIC_DASHBOARD
WHERE OBSERVATION_DATE >= '2000-01-01';

// Revision Tracker (vintage data showing how values get revised)
REVISIONS:
LOAD *;
SQL SELECT
    INDICATOR_CODE,
    INDICATOR_NAME,
    GEO_ID,
    OBSERVATION_DATE,
    RELEASE_DATE,
    VALUE,
    PREV_VALUE,
    REVISION_DELTA
FROM ECON_VAULT.BUSINESS_VAULT.VW_REVISION_TRACKER;

// Latest values per indicator (PIT table)
LATEST_VALUES:
LOAD *;
SQL SELECT
    LINK_HK,
    OBSERVATION_DATE AS LATEST_DATE,
    VALUE AS LATEST_VALUE,
    RECORD_SOURCE
FROM ECON_VAULT.BUSINESS_VAULT.PIT_INDICATOR_LATEST;
```

## Associative Model

| Qlik Table | Key Field | Links To |
|------------|-----------|----------|
| ECONOMIC_DATA | `INDICATOR_CODE` | (self-linking across geos) |
| ECONOMIC_DATA | `GEO_ID` | (filter by geography) |
| REVISIONS | `INDICATOR_CODE` | ECONOMIC_DATA.`INDICATOR_CODE` |

## Suggested Measures

```
// Latest value for selected indicator
Max({<OBSERVATION_DATE={"$(=Max(OBSERVATION_DATE))"}>} VALUE)

// Year-over-year change
(Max({<OBSERVATION_DATE={"$(=Max(OBSERVATION_DATE))"}>} VALUE) -
 Max({<OBSERVATION_DATE={"$(=AddYears(Max(OBSERVATION_DATE),-1))"}>} VALUE))

// Revision magnitude (how much values get revised)
Avg(Abs(REVISION_DELTA))

// Count of data sources
Count(DISTINCT DATA_SOURCE)
```

## Set Analysis

```
// Federal Reserve data only
{<DATA_SOURCE={'FEDERAL_RESERVE'}>}

// US only
{<GEO_ID={'country/USA'}>}

// Post-2020 data
{<OBSERVATION_DATE={">='2020-01-01'"}>}
```
