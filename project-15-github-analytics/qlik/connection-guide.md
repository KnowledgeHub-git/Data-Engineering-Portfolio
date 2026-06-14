# Qlik Cloud Connection — GitHub Developer Analytics

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `GITHUB_ANALYTICS` |
| Schema | `VIEWS` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Load Script

```qlik
LIB CONNECT TO 'Snowflake_GitHub';

STAR_VELOCITY:
LOAD REPO_NAME, "DATE", STARS_ADDED, CUMULATIVE_STARS, STARS_7D_AVG;
SQL SELECT * FROM GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY;

REPO_RANKINGS:
LOAD REPO_NAME, TOTAL_STARS, STARS_LAST_30D, STARS_LAST_7D, STARS_LAST_90D, GROWTH_ACCELERATION;
SQL SELECT * FROM GITHUB_ANALYTICS.VIEWS.REPO_RANKINGS;

CURATED_REPOS:
LOAD REPO_ID, REPO_NAME, FIRST_SEEN, LAST_SEEN;
SQL SELECT * FROM GITHUB_ANALYTICS.STAGING.CURATED_REPOS;
```

## Associative Model

- `REPO_NAME` links all three tables
- `DATE` enables time filtering on STAR_VELOCITY

## Suggested Visualizations

- Line chart: STARS_7D_AVG by DATE per REPO_NAME (star velocity trend)
- Bar chart: STARS_LAST_30D by REPO_NAME (recent momentum)
- KPI: Total stars across all repos, top accelerating project
