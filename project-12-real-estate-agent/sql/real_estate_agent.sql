-- Project 12: Real Estate Investment Advisor Agent
-- 5 tools: investment knowledge search, state HPI, mortgage rates, disaster risk, charts

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS REAL_ESTATE
  COMMENT = 'Real estate investment advisor agent with HPI, mortgage rates, and disaster risk analysis';
CREATE SCHEMA IF NOT EXISTS REAL_ESTATE.STAGING;
CREATE SCHEMA IF NOT EXISTS REAL_ESTATE.SEARCH;
CREATE SCHEMA IF NOT EXISTS REAL_ESTATE.AGENT;
CREATE SCHEMA IF NOT EXISTS REAL_ESTATE.TOOLS;

-- ============================================================
-- 2. KNOWLEDGE BASE (72 curated entries across 8 categories)
-- ============================================================

CREATE OR REPLACE TABLE REAL_ESTATE.STAGING.RE_KNOWLEDGE_BASE (
    CHUNK_ID VARCHAR, CATEGORY VARCHAR, TOPIC VARCHAR, CONTENT VARCHAR
);

-- Categories: Investment Fundamentals (10), Market Analysis (10), Risk Factors (10),
-- Mortgage Analysis (10), Location Criteria (10), Property Types (8),
-- Tax and Legal (6), Market Cycles (8)
-- [INSERT statements omitted - see execution log for full 72 entries]

-- ============================================================
-- 3. CORTEX SEARCH SERVICE
-- ============================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE REAL_ESTATE.SEARCH.RE_KNOWLEDGE_SVC
  ON CONTENT
  ATTRIBUTES CATEGORY, TOPIC
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (SELECT CHUNK_ID, CATEGORY, TOPIC, CONTENT FROM REAL_ESTATE.STAGING.RE_KNOWLEDGE_BASE);

-- ============================================================
-- 4. CUSTOM TOOL UDFs
-- ============================================================

-- State HPI: Freddie Mac House Price Index (last 12 months)
CREATE OR REPLACE FUNCTION REAL_ESTATE.TOOLS.GET_STATE_HPI(P_STATE VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(LINE, '\n') WITHIN GROUP (ORDER BY DT DESC)
  FROM (
    SELECT
      g.GEO_NAME || ' (' || h."DATE"::VARCHAR || '): HPI = ' || ROUND(h.VALUE, 2)::VARCHAR AS LINE,
      h."DATE" AS DT
    FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.FREDDIE_MAC_HOUSING_TIMESERIES h
    JOIN SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.GEOGRAPHY_INDEX g ON h.GEO_ID = g.GEO_ID
    WHERE h.VARIABLE = 'INDEX_SA'
      AND g.LEVEL = 'State'
      AND g.GEO_NAME ILIKE '%' || P_STATE || '%'
    ORDER BY h."DATE" DESC
    LIMIT 12
  )
$$;

-- Current mortgage rates (30yr/15yr/ARM, last 3 weeks)
CREATE OR REPLACE FUNCTION REAL_ESTATE.TOOLS.GET_MORTGAGE_RATES()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(LINE, '\n') WITHIN GROUP (ORDER BY DT DESC, VNAME)
  FROM (
    SELECT
      h.VARIABLE_NAME || ': ' || ROUND(h.VALUE * 100, 2)::VARCHAR || '% (as of ' || h."DATE"::VARCHAR || ')' AS LINE,
      h."DATE" AS DT,
      h.VARIABLE_NAME AS VNAME
    FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.FREDDIE_MAC_HOUSING_TIMESERIES h
    WHERE h.VARIABLE IN ('FRM_30_YR', 'FRM_15_YR', 'ARM_5_1_YR')
      AND h.GEO_ID = 'country/USA'
    ORDER BY h."DATE" DESC
    LIMIT 9
  )
$$;

-- FEMA disaster risk by state (since 2020)
CREATE OR REPLACE FUNCTION REAL_ESTATE.TOOLS.GET_DISASTER_RISK(P_STATE VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(LINE, '\n') WITHIN GROUP (ORDER BY RN)
  FROM (
    SELECT
      CASE
        WHEN RN = 1 THEN 'State: ' || STATE_NAME || ' | Total disaster declarations since 2020: ' || TOTAL_DISASTERS::VARCHAR
        ELSE '  #' || RN::VARCHAR || ': ' || DESIGNATED_DATE::VARCHAR || ' | Programs: ' || LEFT(PROGRAMS, 80)
      END AS LINE,
      RN
    FROM (
      SELECT
        g.GEO_NAME AS STATE_NAME,
        f.DESIGNATED_DATE,
        ARRAY_TO_STRING(f.DECLARED_PROGRAMS_DETAILED, ', ') AS PROGRAMS,
        COUNT(*) OVER (PARTITION BY g.GEO_NAME) AS TOTAL_DISASTERS,
        ROW_NUMBER() OVER (PARTITION BY g.GEO_NAME ORDER BY f.DESIGNATED_DATE DESC) AS RN
      FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.FEMA_DISASTER_DECLARATION_AREAS_INDEX f
      JOIN SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.GEOGRAPHY_INDEX g ON f.STATE_GEO_ID = g.GEO_ID
      WHERE g.GEO_NAME ILIKE '%' || P_STATE || '%'
        AND g.LEVEL = 'State'
        AND f.DESIGNATED_DATE >= '2020-01-01'
    )
    WHERE RN <= 8
  )
$$;

-- ============================================================
-- 5. CORTEX AGENT (5 tools)
-- ============================================================

CREATE OR REPLACE AGENT REAL_ESTATE.AGENT.RE_ADVISOR_AGENT
  COMMENT = 'Real estate investment advisor combining market data, mortgage rates, disaster risk, and investment knowledge'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 16000

  instructions:
    response: "You are a real estate investment advisor. Provide data-driven analysis combining house price trends, mortgage rates, disaster risk, and investment fundamentals. Always include specific numbers and comparisons. When comparing locations, structure the response with clear sections for each factor. Give actionable investment recommendations with reasoning."
    orchestration: "For investment strategy, metrics, analysis methods, property types, tax strategies, and market cycle questions use investment_knowledge. For house price trends and appreciation data by state use get_state_hpi. For current mortgage rate information use get_mortgage_rates. For natural disaster exposure and FEMA history by state use get_disaster_risk. For location comparisons, call get_state_hpi and get_disaster_risk for each location. For complete investment analysis, combine all relevant tools."
    sample_questions:
      - question: "Compare California and Texas for real estate investment"
      - question: "What are current mortgage rates and is it a good time to buy?"
      - question: "Which states have the highest disaster risk for property investors?"
      - question: "Explain the 1% rule and cap rate for rental properties"

  tools:
    - tool_spec:
        type: "cortex_search"
        name: "investment_knowledge"
        description: "Search real estate investment knowledge base covering metrics, market analysis, risk factors, mortgage analysis, location criteria, property types, tax strategies, and market cycles."
    - tool_spec:
        type: "generic"
        name: "get_state_hpi"
        description: "Returns Freddie Mac House Price Index for a US state (last 12 months, seasonally adjusted)."
        input_schema:
          type: object
          properties:
            P_STATE:
              type: string
              description: "US state name (e.g., 'California', 'Texas', 'Florida')"
          required: ["P_STATE"]
    - tool_spec:
        type: "generic"
        name: "get_mortgage_rates"
        description: "Returns current national average mortgage rates (30yr fixed, 15yr fixed, 5/1 ARM) from Freddie Mac."
        input_schema:
          type: object
          properties: {}
    - tool_spec:
        type: "generic"
        name: "get_disaster_risk"
        description: "Returns FEMA disaster history for a US state since 2020 with total count and recent events."
        input_schema:
          type: object
          properties:
            P_STATE:
              type: string
              description: "US state name (e.g., 'Florida', 'California', 'Texas')"
          required: ["P_STATE"]
    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generate charts from real estate data."

  tool_resources:
    investment_knowledge:
      name: "REAL_ESTATE.SEARCH.RE_KNOWLEDGE_SVC"
      max_results: "5"
      columns_and_descriptions:
        CONTENT:
          description: "Real estate investment knowledge"
          type: "string"
          searchable: true
          filterable: false
        CATEGORY:
          description: "Category: Investment Fundamentals, Market Analysis, Risk Factors, Mortgage Analysis, Location Criteria, Property Types, Tax and Legal, Market Cycles"
          type: "string"
          searchable: false
          filterable: true
    get_state_hpi:
      identifier: REAL_ESTATE.TOOLS.GET_STATE_HPI
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    get_mortgage_rates:
      identifier: REAL_ESTATE.TOOLS.GET_MORTGAGE_RATES
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    get_disaster_risk:
      identifier: REAL_ESTATE.TOOLS.GET_DISASTER_RISK
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
  $$;

-- ============================================================
-- 6. EXAMPLE USAGE
-- ============================================================

-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('REAL_ESTATE.AGENT.RE_ADVISOR_AGENT',
--   $${"messages":[{"role":"user","content":[{"type":"text","text":"Compare California and Texas for real estate investment"}]}],"stream":false}$$);
