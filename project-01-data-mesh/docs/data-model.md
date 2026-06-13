# Data Model — Project 01

## Star Schema (Gold Layer)

```
                    ┌─────────────────────┐
                    │  gold_dim_calendar   │
                    │  ─────────────────── │
                    │  CALENDAR_DATE (PK)  │
                    │  YEAR_NUM            │
                    │  MONTH_NUM           │
                    │  QUARTER_NUM         │
                    │  DAY_NAME            │
                    │  IS_WEEKDAY          │
                    │  YEAR_QUARTER_LABEL  │
                    └──────────┬──────────┘
                               │
┌─────────────────────┐        │        ┌─────────────────────┐
│  gold_dim_company   │        │        │  gold_dim_geography  │
│  ─────────────────  │        │        │  ────────────────── │
│  COMPANY_ID (PK)    │        │        │  GEO_ID (PK)        │
│  COMPANY_NAME       │        │        │  GEO_NAME           │
│  PRIMARY_TICKER     │◄───────┤        │  GEO_LEVEL          │
│  PRIMARY_EXCHANGE   │        │        │  ISO_ALPHA2         │
│  CIK / EIN          │        │        │  GEO_LEVEL_DEPTH    │
│  EXCHANGE_REGION    │        │        └─────────────────────┘
└─────────────────────┘        │
           │                   │
           │     ┌─────────────┴────────────────┐
           │     │   gold_fact_stock_prices      │
           └────►│   ──────────────────────────  │
                 │   TICKER (FK → dim_company)   │
                 │   TRADE_DATE (FK → dim_cal)   │
                 │   OPEN_PRICE                  │
                 │   HIGH_PRICE                  │
                 │   LOW_PRICE                   │
                 │   CLOSE_PRICE                 │
                 │   VOLUME                      │
                 │   DAILY_RETURN_PCT            │
                 │   MA_7D / MA_30D             │
                 │   VOLATILITY_30D             │
                 └──────────────────────────────┘
```

## Join Keys

| Fact/Table | Join Key | Dimension |
|-----------|----------|-----------|
| gold_fact_stock_prices.TICKER | = | gold_dim_company.PRIMARY_TICKER |
| gold_fact_stock_prices.TRADE_DATE | = | gold_dim_calendar.CALENDAR_DATE |
| silver_economic_indicators.GEO_ID | = | gold_dim_geography.GEO_ID |

## Row Estimates

| Table | Estimated Rows | Grain |
|-------|---------------|-------|
| gold_fact_stock_prices | ~10-50M | One row per ticker per trading day |
| gold_dim_company | ~100K | One row per company |
| gold_dim_calendar | ~5,500 | One row per day (2010-present) |
| gold_dim_geography | ~200K | One row per geographic entity |
| gold_wide_market_summary | ~10-50K | One row per ticker (latest snapshot) |
