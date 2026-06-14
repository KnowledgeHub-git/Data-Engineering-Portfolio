import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="KPI Suite Dashboard", layout="wide")
session = get_active_session()

st.title("Executive KPI Dashboard")
st.caption("Cross-domain analytics: Market Performance, Economic Indicators, Corporate Financials")

# Navigation
page = st.sidebar.radio("Dashboard", ["Market Performance", "Economic Indicators", "Corporate Financials"])

# === MARKET PERFORMANCE ===
if page == "Market Performance":
    st.header("Market Performance")

    market_df = session.sql("""
        SELECT TICKER, COMPANY_NAME, INDUSTRY, MONTH_DATE, AVG_CLOSE, TOTAL_VOLUME,
               AVG_DAILY_RETURN_PCT, VOLATILITY_PCT
        FROM KPI_SUITE.VIEWS.V_MARKET_KPI
        ORDER BY MONTH_DATE DESC
    """).to_pandas()

    if not market_df.empty:
        # Latest month KPIs
        latest_month = market_df["MONTH_DATE"].max()
        latest = market_df[market_df["MONTH_DATE"] == latest_month]

        col1, col2, col3, col4 = st.columns(4)
        col1.metric("Tickers Tracked", len(latest["TICKER"].unique()))
        if not latest.empty:
            best = latest.loc[latest["AVG_DAILY_RETURN_PCT"].idxmax()]
            worst = latest.loc[latest["AVG_DAILY_RETURN_PCT"].idxmin()]
            col2.metric("Top Performer", best["TICKER"], f"{best['AVG_DAILY_RETURN_PCT']:.2f}%")
            col3.metric("Worst Performer", worst["TICKER"], f"{worst['AVG_DAILY_RETURN_PCT']:.2f}%")
            col4.metric("Avg Volatility", f"{latest['VOLATILITY_PCT'].mean():.2f}%")

        # Ticker filter
        tickers = sorted(market_df["TICKER"].unique())
        selected = st.multiselect("Filter tickers", tickers, default=tickers[:5])

        if selected:
            filtered = market_df[market_df["TICKER"].isin(selected)]
            st.subheader("Average Close Price Trend")
            chart_data = filtered.pivot_table(index="MONTH_DATE", columns="TICKER", values="AVG_CLOSE")
            st.line_chart(chart_data)

            st.subheader("Monthly Volume")
            vol_data = filtered.pivot_table(index="MONTH_DATE", columns="TICKER", values="TOTAL_VOLUME")
            st.bar_chart(vol_data)

# === ECONOMIC INDICATORS ===
elif page == "Economic Indicators":
    st.header("Economic Indicators")

    econ_df = session.sql("""
        SELECT INDICATOR_GROUP, INDICATOR, "DATE", VALUE, UNIT
        FROM KPI_SUITE.VIEWS.V_ECONOMY_KPI
        WHERE INDICATOR_GROUP != 'Other'
        ORDER BY "DATE" DESC
    """).to_pandas()

    if not econ_df.empty:
        # Latest values per group
        groups = econ_df.groupby("INDICATOR_GROUP").first().reset_index()

        cols = st.columns(min(len(groups), 4))
        for i, row in groups.iterrows():
            if i < 4:
                cols[i].metric(row["INDICATOR_GROUP"], f"{row['VALUE']:.2f}", row["UNIT"])

        # Time series by indicator group
        selected_group = st.selectbox("Indicator Group", sorted(econ_df["INDICATOR_GROUP"].unique()))
        group_data = econ_df[econ_df["INDICATOR_GROUP"] == selected_group]

        if not group_data.empty:
            st.subheader(f"{selected_group} Trend")
            chart = group_data[["DATE", "VALUE"]].set_index("DATE").sort_index()
            st.line_chart(chart)

# === CORPORATE FINANCIALS ===
elif page == "Corporate Financials":
    st.header("Corporate Financials")

    corp_df = session.sql("""
        SELECT COMPANY_NAME, TICKER, INDUSTRY, METRIC_TAG, AMOUNT, PERIOD_END_DATE, "YEAR", "QUARTER"
        FROM KPI_SUITE.VIEWS.V_CORPORATE_KPI
        WHERE COMPANY_NAME IS NOT NULL
        ORDER BY PERIOD_END_DATE DESC
    """).to_pandas()

    if not corp_df.empty:
        # Filters
        col1, col2 = st.columns(2)
        with col1:
            metrics = sorted(corp_df["METRIC_TAG"].unique())
            selected_metric = st.selectbox("Metric", metrics, index=metrics.index("Revenues") if "Revenues" in metrics else 0)
        with col2:
            companies = sorted(corp_df[corp_df["COMPANY_NAME"].notna()]["COMPANY_NAME"].unique())[:20]
            selected_companies = st.multiselect("Companies (top 20)", companies, default=companies[:5])

        filtered = corp_df[(corp_df["METRIC_TAG"] == selected_metric) & (corp_df["COMPANY_NAME"].isin(selected_companies))]

        if not filtered.empty:
            # Latest quarter comparison
            st.subheader(f"{selected_metric} by Company (Latest Period)")
            latest_year = filtered["YEAR"].max()
            latest_q = filtered[filtered["YEAR"] == latest_year]["QUARTER"].max()
            latest_data = filtered[(filtered["YEAR"] == latest_year) & (filtered["QUARTER"] == latest_q)]

            if not latest_data.empty:
                bar_data = latest_data[["COMPANY_NAME", "AMOUNT"]].set_index("COMPANY_NAME")
                st.bar_chart(bar_data)

            # Quarterly trend
            st.subheader(f"{selected_metric} Quarterly Trend")
            trend = filtered.pivot_table(index="PERIOD_END_DATE", columns="COMPANY_NAME", values="AMOUNT", aggfunc="sum")
            st.line_chart(trend)
