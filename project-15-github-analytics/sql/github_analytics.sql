-- Project 15: GitHub Developer Analytics (minimal credit version)
-- Stars-only approach: ~0.3 credits using GITHUB_STARS + GITHUB_REPOS

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS GITHUB_ANALYTICS
  COMMENT = 'GitHub developer analytics - star velocity and project momentum for top data/AI repos';
CREATE SCHEMA IF NOT EXISTS GITHUB_ANALYTICS.STAGING;
CREATE SCHEMA IF NOT EXISTS GITHUB_ANALYTICS.VIEWS;

-- ============================================================
-- 2. CURATED REPOS (30 top data/AI open-source projects)
-- ============================================================

CREATE OR REPLACE TABLE GITHUB_ANALYTICS.STAGING.CURATED_REPOS AS
SELECT REPO_ID, REPO_NAME, FIRST_SEEN, LAST_SEEN
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.GITHUB_REPOS
WHERE REPO_NAME IN (
    'snowflakedb/snowflake-cli','dbt-labs/dbt-core','streamlit/streamlit',
    'langchain-ai/langchain','run-llama/llama_index','huggingface/transformers',
    'pytorch/pytorch','tensorflow/tensorflow','apache/spark','apache/airflow',
    'pandas-dev/pandas','pola-rs/polars','duckdb/duckdb','tiangolo/fastapi',
    'mlflow/mlflow','ray-project/ray','gradio-app/gradio','openai/openai-python',
    'anthropics/anthropic-sdk-python','meta-llama/llama','mistralai/mistral-src',
    'microsoft/autogen','crewAIInc/crewAI','letta-ai/letta','qdrant/qdrant',
    'chroma-core/chroma','pgvector/pgvector','supabase/supabase','vercel/next.js',
    'tailwindlabs/tailwindcss'
);

-- ============================================================
-- 3. STAR VELOCITY (daily star additions with 7-day moving avg)
-- ============================================================

CREATE OR REPLACE TABLE GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY AS
SELECT
    r.REPO_NAME,
    s."DATE",
    s."COUNT" AS STARS_ADDED,
    SUM(s."COUNT") OVER (PARTITION BY r.REPO_NAME ORDER BY s."DATE") AS CUMULATIVE_STARS,
    ROUND(AVG(s."COUNT") OVER (PARTITION BY r.REPO_NAME ORDER BY s."DATE" ROWS 6 PRECEDING), 1) AS STARS_7D_AVG
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.GITHUB_STARS s
JOIN GITHUB_ANALYTICS.STAGING.CURATED_REPOS r ON s.REPO_ID = r.REPO_ID
WHERE s."DATE" >= '2024-01-01';

-- ============================================================
-- 4. REPO RANKINGS (summary with momentum metrics)
-- ============================================================

CREATE OR REPLACE VIEW GITHUB_ANALYTICS.VIEWS.REPO_RANKINGS AS
SELECT
    REPO_NAME,
    MAX(CUMULATIVE_STARS) AS TOTAL_STARS,
    SUM(CASE WHEN "DATE" >= CURRENT_DATE() - 30 THEN STARS_ADDED ELSE 0 END) AS STARS_LAST_30D,
    SUM(CASE WHEN "DATE" >= CURRENT_DATE() - 7 THEN STARS_ADDED ELSE 0 END) AS STARS_LAST_7D,
    SUM(CASE WHEN "DATE" >= CURRENT_DATE() - 90 THEN STARS_ADDED ELSE 0 END) AS STARS_LAST_90D,
    ROUND(SUM(CASE WHEN "DATE" >= CURRENT_DATE() - 7 THEN STARS_ADDED ELSE 0 END)::FLOAT /
          NULLIF(SUM(CASE WHEN "DATE" BETWEEN CURRENT_DATE() - 37 AND CURRENT_DATE() - 8 THEN STARS_ADDED ELSE 0 END)::FLOAT / 4.0, 0), 2) AS GROWTH_ACCELERATION
FROM GITHUB_ANALYTICS.VIEWS.STAR_VELOCITY
GROUP BY REPO_NAME;
