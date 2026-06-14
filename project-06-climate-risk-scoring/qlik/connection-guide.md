# Qlik Connection Guide — Project 06 Climate Risk

## Connection Settings

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Database** | `CLIMATE_RISK` |
| **Schema** | `RESULTS` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |

## Load Script

```qvs
LIB CONNECT TO 'Snowflake_ClimateRisk';

FEATURE_STORE:
LOAD *;
SQL SELECT GEO_ID, COUNTRY_NAME, OBSERVATION_DATE,
    TOTAL_GHG, ENERGY_GHG, AGRICULTURE_GHG, INDUSTRIAL_GHG,
    ENERGY_SHARE, AGRICULTURE_SHARE, RISK_TIER, PREDICTED_TIER
FROM CLIMATE_RISK.RESULTS.FEATURE_STORE_CLIMATE;

EMISSIONS_TRENDS:
LOAD *;
SQL SELECT GEO_ID, COUNTRY_NAME, OBSERVATION_DATE,
    TOTAL_GHG, YOY_CHANGE_PCT
FROM CLIMATE_RISK.RESULTS.EMISSIONS_TRENDS;
```

## Measures

```
// Total GHG for selected country
Sum(TOTAL_GHG)

// YoY emissions change
Avg(YOY_CHANGE_PCT)

// Countries at high risk
Count({<RISK_TIER={'High Risk'}>} DISTINCT GEO_ID)
```
