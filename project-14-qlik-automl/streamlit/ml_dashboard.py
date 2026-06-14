import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="ML Pipeline Dashboard", layout="wide")
session = get_active_session()

st.title("AutoML Pipeline Dashboard")
st.caption("Feature store overview, model comparison, and feature analysis across 3 ML use cases")

page = st.sidebar.radio("Dashboard", ["Feature Store", "Model Comparison", "Feature Analysis"])

# === FEATURE STORE ===
if page == "Feature Store":
    st.header("Feature Store Overview")

    stats = session.sql("""
        SELECT 'Stock Direction' AS DATASET, COUNT(*) AS ROW_CNT, 9 AS FEATURE_CNT, 'DIRECTION (UP/DOWN)' AS TARGET
        FROM AUTOML_PIPELINE.FEATURES.STOCK_RETURN_FEATURES
        UNION ALL
        SELECT 'Provider Risk', COUNT(*), 6, 'IS_DEACTIVATED (0/1)'
        FROM AUTOML_PIPELINE.FEATURES.PROVIDER_RISK_FEATURES
        UNION ALL
        SELECT 'Climate Risk', COUNT(*), 9, 'RISK_TIER (H/M/L)'
        FROM AUTOML_PIPELINE.FEATURES.CLIMATE_RISK_FEATURES
    """).to_pandas()

    st.dataframe(stats, use_container_width=True)

    st.divider()

    # Target distribution
    st.subheader("Target Variable Distributions")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.markdown("**Stock Direction**")
        stock_dist = session.sql("""
            SELECT DIRECTION, COUNT(*) AS CNT
            FROM AUTOML_PIPELINE.FEATURES.STOCK_RETURN_FEATURES
            WHERE DIRECTION IS NOT NULL GROUP BY 1
        """).to_pandas()
        st.bar_chart(stock_dist.set_index("DIRECTION"))

    with col2:
        st.markdown("**Provider Deactivation**")
        prov_dist = session.sql("""
            SELECT CASE WHEN IS_DEACTIVATED = 1 THEN 'Deactivated' ELSE 'Active' END AS STATUS, COUNT(*) AS CNT
            FROM AUTOML_PIPELINE.FEATURES.PROVIDER_RISK_FEATURES GROUP BY 1
        """).to_pandas()
        st.bar_chart(prov_dist.set_index("STATUS"))

    with col3:
        st.markdown("**Climate Risk Tier**")
        climate_dist = session.sql("""
            SELECT RISK_TIER, COUNT(*) AS CNT
            FROM AUTOML_PIPELINE.FEATURES.CLIMATE_RISK_FEATURES GROUP BY 1
        """).to_pandas()
        st.bar_chart(climate_dist.set_index("RISK_TIER"))

# === MODEL COMPARISON ===
elif page == "Model Comparison":
    st.header("Model Comparison: Cortex ML vs Qlik AutoML")

    models = session.sql("""
        SELECT MODEL_NAME, PLATFORM, MODEL_TYPE, DESCRIPTION, METRICS, SAMPLE_SIZE, TRAINED_DATE
        FROM AUTOML_PIPELINE.RESULTS.MODEL_COMPARISON
        ORDER BY PLATFORM, MODEL_NAME
    """).to_pandas()

    # Split by platform
    cortex = models[models["PLATFORM"] == "Cortex ML"]
    qlik = models[models["PLATFORM"].str.contains("Qlik")]

    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Cortex ML (Trained)")
        st.dataframe(cortex[["MODEL_NAME", "MODEL_TYPE", "METRICS", "SAMPLE_SIZE"]], use_container_width=True)

    with col2:
        st.subheader("Qlik AutoML (Pending)")
        st.dataframe(qlik[["MODEL_NAME", "MODEL_TYPE", "DESCRIPTION", "SAMPLE_SIZE"]], use_container_width=True)

    st.divider()
    st.info("Train Qlik AutoML models by connecting to AUTOML_PIPELINE.FEATURES in Qlik Cloud ML > Experiments")

# === FEATURE ANALYSIS ===
elif page == "Feature Analysis":
    st.header("Feature Analysis")

    dataset = st.selectbox("Select dataset", ["Stock Direction", "Provider Risk", "Climate Risk"])

    if dataset == "Stock Direction":
        df = session.sql("""
            SELECT PRICE_TO_SMA20_RATIO, PRICE_TO_SMA50_RATIO, BOLLINGER_PCT_B,
                   RSI_14, MACD_APPROX, VOLATILITY_20D, VOLUME_RATIO, DIRECTION
            FROM AUTOML_PIPELINE.FEATURES.STOCK_RETURN_FEATURES
            WHERE DIRECTION IS NOT NULL
            LIMIT 1000
        """).to_pandas()
        st.markdown("**Feature Statistics**")
        st.dataframe(df.describe(), use_container_width=True)
        st.subheader("RSI Distribution by Direction")
        st.bar_chart(df.groupby("DIRECTION")["RSI_14"].mean())

    elif dataset == "Provider Risk":
        df = session.sql("""
            SELECT SPECIALTY_GROUP, COUNT(*) AS CNT,
                   ROUND(AVG(IS_DEACTIVATED)*100, 1) AS DEACTIVATION_RATE_PCT
            FROM AUTOML_PIPELINE.FEATURES.PROVIDER_RISK_FEATURES
            GROUP BY 1 ORDER BY 3 DESC LIMIT 15
        """).to_pandas()
        st.markdown("**Deactivation Rate by Specialty**")
        st.bar_chart(df.set_index("SPECIALTY_GROUP")["DEACTIVATION_RATE_PCT"])

    elif dataset == "Climate Risk":
        df = session.sql("""
            SELECT RISK_TIER, ROUND(AVG(TOTAL_GHG_MT), 1) AS AVG_GHG,
                   ROUND(AVG(ENERGY_SHARE_PCT), 1) AS AVG_ENERGY_PCT,
                   ROUND(AVG(AGRICULTURE_SHARE_PCT), 1) AS AVG_AGRI_PCT
            FROM AUTOML_PIPELINE.FEATURES.CLIMATE_RISK_FEATURES
            GROUP BY 1 ORDER BY AVG_GHG DESC
        """).to_pandas()
        st.markdown("**Average Features by Risk Tier**")
        st.dataframe(df, use_container_width=True)
        st.bar_chart(df.set_index("RISK_TIER")["AVG_GHG"])
