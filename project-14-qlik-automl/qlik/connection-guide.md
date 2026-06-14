# Qlik Cloud Connection — AutoML Pipeline

## Connection Settings

| Field | Value |
|-------|-------|
| Server | `prb43560.snowflakecomputing.com` |
| Port | `443` |
| Database | `AUTOML_PIPELINE` |
| Schema | `FEATURES` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |
| User | `BIWARO` |
| Auth | Username + Password |

## Feature Tables for Qlik AutoML

### 1. Stock Direction Prediction (Classification)

| Field | Description |
|-------|-------------|
| Table | `AUTOML_PIPELINE.FEATURES.STOCK_RETURN_FEATURES` |
| Rows | 12,816 |
| Target | `DIRECTION` (UP / DOWN) |
| Features | PRICE_TO_SMA20_RATIO, PRICE_TO_SMA50_RATIO, BOLLINGER_PCT_B, RSI_14, MACD_APPROX, VOLATILITY_20D, VOLUME_RATIO, PREV_DAY_RETURN |
| Exclude | TICKER, DATE (identifiers, not features) |

### 2. Provider Deactivation Risk (Classification)

| Field | Description |
|-------|-------------|
| Table | `AUTOML_PIPELINE.FEATURES.PROVIDER_RISK_FEATURES` |
| Rows | 10,000 |
| Target | `IS_DEACTIVATED` (1 / 0) |
| Features | YEARS_ACTIVE, GENDER, SPECIALTY_GROUP, STATE, IS_SOLE_PROPRIETOR, HAS_CREDENTIAL |
| Notes | Mixed categorical/numeric — Qlik AutoML handles encoding automatically |

### 3. Country Climate Risk Tier (Classification)

| Field | Description |
|-------|-------------|
| Table | `AUTOML_PIPELINE.FEATURES.CLIMATE_RISK_FEATURES` |
| Rows | 5,000 |
| Target | `RISK_TIER` (High Risk / Medium Risk / Low Risk) |
| Features | TOTAL_GHG_MT, ENERGY_GHG_MT, AGRICULTURE_GHG_MT, WASTE_GHG_MT, INDUSTRIAL_GHG_MT, ENERGY_SHARE_PCT, AGRICULTURE_SHARE_PCT |
| Exclude | COUNTRY_NAME, YEAR (identifiers) |

## Qlik AutoML Training Steps

### Step 1: Connect to Snowflake
1. In Qlik Cloud, go to **Data** > **Data connections** > **Create new**
2. Select **Snowflake** connector
3. Enter connection settings from above
4. Test connection and save as `Snowflake_AutoML`

### Step 2: Create AutoML Experiment
1. Go to **ML** > **Experiments** > **Create experiment**
2. Select `Snowflake_AutoML` as data source
3. Choose one of the three feature tables
4. Configure:
   - **Target**: Select the target column (DIRECTION / IS_DEACTIVATED / RISK_TIER)
   - **Features**: Auto-select all (exclude identifier columns)
   - **Training**: 80/20 split, 5-fold cross-validation
   - **Algorithms**: Let AutoML select (gradient boosting, random forest, logistic regression)

### Step 3: Train and Evaluate
1. Click **Train model**
2. Review: accuracy, confusion matrix, ROC/AUC, feature importance (SHAP)
3. Compare with Cortex ML baseline metrics in `AUTOML_PIPELINE.RESULTS.MODEL_COMPARISON`

### Step 4: Deploy and Write Back (Optional)
1. **Deploy** the best model as a prediction endpoint
2. **Write back** predictions to Snowflake:
   ```sql
   -- Create a writeback table for Qlik predictions
   CREATE TABLE IF NOT EXISTS AUTOML_PIPELINE.RESULTS.QLIK_PREDICTIONS (
       EXPERIMENT_NAME VARCHAR,
       PREDICTION VARCHAR,
       CONFIDENCE FLOAT,
       CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
   );
   ```
3. In Qlik, configure **Action** > **Write to Snowflake** targeting the predictions table

## Model Comparison (Cortex ML vs Qlik AutoML)

| Model | Platform | Status | Metrics |
|-------|----------|--------|---------|
| STOCK_FORECAST_MODEL | Cortex ML | Trained | RMSE: 12.4 |
| PRICE_ANOMALY_MODEL | Cortex ML | Trained | Precision: 0.85 |
| DEACTIVATION_CLASSIFIER | Cortex ML | Trained | Accuracy: 0.89 |
| RISK_TIER_CLASSIFIER | Cortex ML | Trained | Accuracy: 1.00 |
| STOCK_DIRECTION_AUTOML | Qlik AutoML | Pending | Train in Qlik UI |
| PROVIDER_RISK_AUTOML | Qlik AutoML | Pending | Train in Qlik UI |
| CLIMATE_TIER_AUTOML | Qlik AutoML | Pending | Train in Qlik UI |
