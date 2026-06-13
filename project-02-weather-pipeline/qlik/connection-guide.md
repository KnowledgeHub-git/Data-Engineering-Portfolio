# Qlik Connection Guide — Project 02 Weather Pipeline

## Connection Settings (Verified)

| Field | Value |
|-------|-------|
| **Server** | `prb43560.snowflakecomputing.com` |
| **Port** | `443` |
| **Database** | `WEATHER_DOMAIN` |
| **Schema** | `CURATED` |
| **Warehouse** | `COMPUTE_WH` |
| **Role** | `ACCOUNTADMIN` |
| **User** | `BIWARO` |
| **Auth** | Username + Password |

> Create the connection from within the Qlik app's Data Load Editor to ensure it's scoped correctly.

## Recommended Load Script

```qvs
// =============================================================
// Qlik Sense Load Script — Weather Pipeline POC
// Loads from WEATHER_DOMAIN.CURATED
// =============================================================

LIB CONNECT TO 'Snowflake_Weather';

// Station dimension (reference)
STATION_INDEX:
LOAD *;
SQL SELECT
    NWS_WEATHER_STATION_ID,
    NWS_WEATHER_STATION_NAME,
    COUNTY_GEO_ID,
    STATE_GEO_ID,
    LATITUDE,
    LONGITUDE,
    ELEVATION,
    TIMEZONE
FROM WEATHER_DOMAIN.RAW.STATION_INDEX;

// Latest station readings (current conditions - pivoted wide)
LATEST_READINGS:
LOAD *;
SQL SELECT
    NWS_WEATHER_STATION_ID,
    LAST_OBSERVATION_TIME,
    TEMPERATURE_C,
    DEW_POINT_C,
    HUMIDITY_PCT,
    WIND_SPEED_KPH,
    WIND_GUST_KPH,
    PRESSURE_PA,
    VISIBILITY_M
FROM WEATHER_DOMAIN.CURATED.LATEST_STATION_READINGS;

// Daily summaries (trends)
DAILY_SUMMARIES:
LOAD *;
SQL SELECT
    NWS_WEATHER_STATION_ID,
    OBSERVATION_DATE,
    VARIABLE,
    TOTAL_READINGS,
    DAY_AVG,
    DAY_MIN,
    DAY_MAX
FROM WEATHER_DOMAIN.CURATED.DAILY_SUMMARIES;

// Active weather alerts
ACTIVE_ALERTS:
LOAD *;
SQL SELECT
    COUNTY_GEO_ID,
    NWS_ALERT_ID,
    EVENT_TYPE,
    EVENT_SEVERITY,
    EVENT_URGENCY,
    ALERT_TITLE,
    SENT_TIMESTAMP,
    EXPIRATION_TIMESTAMP,
    COUNTY_NAME,
    STATE_CODE
FROM WEATHER_DOMAIN.CURATED.ACTIVE_ALERTS;

// Alert history (triggered threshold breaches)
ALERT_HISTORY:
LOAD *;
SQL SELECT
    ALERT_NAME,
    TRIGGERED_AT,
    STATION_ID,
    METRIC_NAME,
    METRIC_VALUE,
    MESSAGE
FROM WEATHER_DOMAIN.PRODUCTS.ALERT_HISTORY;
```

## Associative Model — Key Links

| Qlik Table | Key Field | Links To |
|------------|-----------|----------|
| LATEST_READINGS | `NWS_WEATHER_STATION_ID` | STATION_INDEX.`NWS_WEATHER_STATION_ID` |
| DAILY_SUMMARIES | `NWS_WEATHER_STATION_ID` | STATION_INDEX.`NWS_WEATHER_STATION_ID` |
| ACTIVE_ALERTS | `COUNTY_GEO_ID` | STATION_INDEX.`COUNTY_GEO_ID` |
| ALERT_HISTORY | `STATION_ID` | STATION_INDEX.`NWS_WEATHER_STATION_ID` |

## Suggested Measures

```
// Current temperature (latest reading)
Avg(TEMPERATURE_C)

// Wind chill / Heat index feel
If(TEMPERATURE_C < 10,
    13.12 + 0.6215*TEMPERATURE_C - 11.37*Power(WIND_SPEED_KPH, 0.16) + 0.3965*TEMPERATURE_C*Power(WIND_SPEED_KPH, 0.16),
    TEMPERATURE_C)

// Active alert count
Count(DISTINCT NWS_ALERT_ID)

// Stations reporting
Count(DISTINCT NWS_WEATHER_STATION_ID)

// Max wind gust
Max(WIND_GUST_KPH)
```

## Set Analysis Examples

```
// Only Extreme severity alerts
{<EVENT_SEVERITY={'Extreme'}>}

// Stations in a specific state
{<STATE_GEO_ID={'geoId/06'}>}

// Temperature readings only
{<VARIABLE={'temperature'}>}
```
