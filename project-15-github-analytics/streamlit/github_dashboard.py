import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="GitHub Analytics", layout="wide")
session = get_active_session()

st.title("GitHub Developer Analytics")
st.caption("Star velocity and project momentum for top 30 data/AI open-source projects")

page = st.sidebar.radio("Dashboard", ["Project Rankings", "Star Velocity"])

# === PROJECT RANKINGS ===
if page == "Project Rankings":
    st.header("Project Rankings by Momentum")

    rankings = session.sql("""
        SELECT REPO_NAME, TOTAL_STARS, STARS_LAST_30D, STARS_LAST_7D, STARS_LAST_90D, GROWTH_ACCELERATION
        FROM GITHUB_ANALYTICS.VIEWS.REPO_RANKINGS
        ORDER BY STARS_LAST_30D DESC
    """).to_pandas()

    if not rankings.empty:
        # KPI cards
        col1, col2, col3 = st.columns(3)
        col1.metric("Top Project (30d)", rankings.iloc[0]["REPO_NAME"].split("/")[1], f"+{int(rankings.iloc[0]['STARS_LAST_30D'])} stars")
        col2.metric("Total Repos Tracked", len(rankings))
        col3.metric("Total Stars (all repos)", f"{int(rankings['TOTAL_STARS'].sum()):,}")

        st.divider()

        # Bar chart - stars last 30 days
        st.subheader("Stars Added (Last 30 Days)")
        chart_data = rankings[["REPO_NAME", "STARS_LAST_30D"]].head(15)
        chart_data["REPO_SHORT"] = chart_data["REPO_NAME"].apply(lambda x: x.split("/")[1])
        st.bar_chart(chart_data.set_index("REPO_SHORT")["STARS_LAST_30D"])

        # Full table
        st.subheader("Full Rankings")
        display_df = rankings[["REPO_NAME", "TOTAL_STARS", "STARS_LAST_90D", "STARS_LAST_30D", "STARS_LAST_7D", "GROWTH_ACCELERATION"]]
        display_df.columns = ["Repo", "Total Stars", "Last 90d", "Last 30d", "Last 7d", "Acceleration"]
        st.dataframe(display_df, use_container_width=True)

# === STAR VELOCITY ===
elif page == "Star Velocity":
    st.header("Star Velocity Over Time")

    repos = session.sql("SELECT DISTINCT REPO_NAME FROM GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY ORDER BY 1").to_pandas()["REPO_NAME"].tolist()
    repo_short = [r.split("/")[1] for r in repos]
    selected_short = st.multiselect("Select repos to compare", repo_short, default=repo_short[:5])
    selected_repos = [repos[repo_short.index(s)] for s in selected_short]

    if selected_repos:
        repo_filter = "','".join(selected_repos)
        velocity_df = session.sql(f"""
            SELECT REPO_NAME, DATE_TRUNC('WEEK', "DATE")::DATE AS WEEK_DATE, SUM(STARS_ADDED) AS WEEKLY_STARS
            FROM GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY
            WHERE REPO_NAME IN ('{repo_filter}')
            AND "DATE" >= '2024-06-01'
            GROUP BY 1, 2 ORDER BY 2
        """).to_pandas()

        if not velocity_df.empty:
            velocity_df["REPO_SHORT"] = velocity_df["REPO_NAME"].apply(lambda x: x.split("/")[1])
            pivot = velocity_df.pivot_table(index="WEEK_DATE", columns="REPO_SHORT", values="WEEKLY_STARS", aggfunc="sum").fillna(0)
            st.subheader("Weekly Stars Added")
            st.line_chart(pivot)

            # Cumulative view
            st.subheader("Cumulative Stars (since Jan 2024)")
            cum_df = session.sql(f"""
                SELECT REPO_NAME, "DATE", CUMULATIVE_STARS
                FROM GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY
                WHERE REPO_NAME IN ('{repo_filter}')
                AND "DATE" >= '2024-06-01'
                AND DAYOFWEEK("DATE") = 1
                ORDER BY "DATE"
            """).to_pandas()
            if not cum_df.empty:
                cum_df["REPO_SHORT"] = cum_df["REPO_NAME"].apply(lambda x: x.split("/")[1])
                cum_pivot = cum_df.pivot_table(index="DATE", columns="REPO_SHORT", values="CUMULATIVE_STARS")
                st.line_chart(cum_pivot)
