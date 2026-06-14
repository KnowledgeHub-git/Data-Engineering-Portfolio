-- Project 11: Climate & ESG Compliance Agent
-- 5 tools: regulations search, SEC filings search, country emissions, trend analysis, charts

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS CLIMATE_ESG
  COMMENT = 'Climate & ESG compliance agent with regulations search, emissions data, and SEC disclosures';
CREATE SCHEMA IF NOT EXISTS CLIMATE_ESG.STAGING;
CREATE SCHEMA IF NOT EXISTS CLIMATE_ESG.SEARCH;
CREATE SCHEMA IF NOT EXISTS CLIMATE_ESG.AGENT;
CREATE SCHEMA IF NOT EXISTS CLIMATE_ESG.TOOLS;

-- ============================================================
-- 2. ESG FRAMEWORKS KNOWLEDGE BASE (88 curated entries)
-- ============================================================

CREATE OR REPLACE TABLE CLIMATE_ESG.STAGING.ESG_KNOWLEDGE_BASE (
    CHUNK_ID VARCHAR,
    FRAMEWORK VARCHAR,
    SECTION VARCHAR,
    CONTENT VARCHAR,
    SOURCE_REF VARCHAR
);

-- Frameworks covered: Paris Agreement (10), EU CSRD (12), TCFD (10),
-- GHG Protocol (10), SBTi (10), EU Taxonomy (5), SEC Climate Rule (5),
-- GRI Standards (4), Sector Thresholds (12), Climate Risk Assessment (6),
-- Compliance Checklist (4)

-- [INSERT statements omitted for brevity - see execution log for full 88 entries]
-- Each entry provides: framework name, section, regulatory content summary, source reference

-- ============================================================
-- 3. CORTEX SEARCH SERVICE
-- ============================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE CLIMATE_ESG.SEARCH.ESG_REGULATIONS_SVC
  ON CONTENT
  ATTRIBUTES FRAMEWORK, SECTION
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (SELECT CHUNK_ID, FRAMEWORK, SECTION, CONTENT FROM CLIMATE_ESG.STAGING.ESG_KNOWLEDGE_BASE);

-- ============================================================
-- 4. CUSTOM TOOL UDFs
-- ============================================================

-- Country emissions profile: total GHG, sector breakdown, risk tier (5-year window)
CREATE OR REPLACE FUNCTION CLIMATE_ESG.TOOLS.GET_COUNTRY_EMISSIONS(P_COUNTRY VARCHAR, P_YEAR INT DEFAULT 2021)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(LINE, '\n') WITHIN GROUP (ORDER BY OBSERVATION_DATE DESC)
  FROM (
    SELECT 
      COUNTRY_NAME || ' (' || OBSERVATION_DATE::VARCHAR || ')' ||
      ' | Total GHG: ' || ROUND(TOTAL_GHG/1000000, 1)::VARCHAR || ' MtCO2e' ||
      ' | Energy: ' || ROUND(ENERGY_SHARE*100, 1)::VARCHAR || '%' ||
      ' | Agriculture: ' || ROUND(AGRICULTURE_SHARE*100, 1)::VARCHAR || '%' ||
      ' | Risk Tier: ' || RISK_TIER ||
      ' | Predicted: ' || PREDICTED_TIER AS LINE,
      OBSERVATION_DATE
    FROM CLIMATE_RISK.RESULTS.FEATURE_STORE_CLIMATE
    WHERE COUNTRY_NAME ILIKE '%' || P_COUNTRY || '%'
      AND YEAR(OBSERVATION_DATE) >= P_YEAR - 5
      AND YEAR(OBSERVATION_DATE) <= P_YEAR
    ORDER BY OBSERVATION_DATE DESC
    LIMIT 6
  )
$$;

-- Emissions trajectory: YoY changes for top 50 emitters (10-year history)
CREATE OR REPLACE FUNCTION CLIMATE_ESG.TOOLS.GET_EMISSIONS_TREND(P_COUNTRY VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(LINE, '\n') WITHIN GROUP (ORDER BY OBSERVATION_DATE DESC)
  FROM (
    SELECT 
      COUNTRY_NAME || ' ' || YEAR(OBSERVATION_DATE)::VARCHAR ||
      ': ' || ROUND(TOTAL_GHG/1000000, 1)::VARCHAR || ' MtCO2e' ||
      ' (YoY: ' || CASE WHEN YOY_CHANGE_PCT > 0 THEN '+' ELSE '' END || ROUND(YOY_CHANGE_PCT, 2)::VARCHAR || '%)' AS LINE,
      OBSERVATION_DATE
    FROM CLIMATE_RISK.RESULTS.EMISSIONS_TRENDS
    WHERE COUNTRY_NAME ILIKE '%' || P_COUNTRY || '%'
    ORDER BY OBSERVATION_DATE DESC
    LIMIT 10
  )
$$;

-- ============================================================
-- 5. CORTEX AGENT (5 tools)
-- ============================================================

CREATE OR REPLACE AGENT CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT
  COMMENT = 'Climate & ESG compliance agent for regulatory assessment, emissions analysis, and corporate disclosure review'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 16000

  instructions:
    response: "You are an ESG compliance analyst specializing in climate regulations and corporate sustainability reporting. Provide precise, evidence-based answers with citations to specific frameworks and standards. When assessing compliance, clearly state which requirements are met and which are not. Include specific numbers, thresholds, and regulatory references."
    orchestration: "For questions about ESG regulations, standards, frameworks, disclosure requirements, or compliance criteria use regulations_search. For company-specific climate disclosures, risk factors, and environmental narratives in SEC filings use filings_climate_search. For country-level emissions data, sector breakdowns, and risk tier classification use get_country_emissions. For emissions trajectory and year-over-year trends use get_emissions_trend. For complex compliance assessments, combine regulatory requirements with actual emissions data and company disclosures. Always cite the specific framework and section."
    sample_questions:
      - question: "Is China on track to meet Paris Agreement targets based on their emissions trajectory?"
      - question: "What are the TCFD disclosure requirements for governance?"
      - question: "What does ExxonMobil disclose about climate risks in their SEC filings?"
      - question: "What are the EU Taxonomy thresholds for steel production?"
      - question: "Compare India and Japan emissions intensity and NDC compliance"

  tools:
    - tool_spec:
        type: "cortex_search"
        name: "regulations_search"
        description: "Search ESG regulatory frameworks, standards, and compliance requirements. Covers Paris Agreement, EU CSRD, TCFD, GHG Protocol, SBTi, EU Taxonomy, SEC Climate Rule, GRI Standards, sector-specific thresholds, and compliance checklists."
    - tool_spec:
        type: "cortex_search"
        name: "filings_climate_search"
        description: "Search SEC 10-K and 10-Q filing sections for climate-related disclosures from 49 major companies. Use for company-specific ESG narrative analysis."
    - tool_spec:
        type: "generic"
        name: "get_country_emissions"
        description: "Returns a country's emissions profile including total GHG (MtCO2e), energy share, agriculture share, and climate risk tier. Shows 5-year history."
        input_schema:
          type: object
          properties:
            P_COUNTRY:
              type: string
              description: "Country name (e.g., 'China', 'India', 'United States')"
            P_YEAR:
              type: integer
              description: "End year for 5-year window (default 2021)"
          required: ["P_COUNTRY"]
    - tool_spec:
        type: "generic"
        name: "get_emissions_trend"
        description: "Returns year-over-year emissions trajectory for top 50 emitting countries. Shows total GHG and percentage change for up to 10 years."
        input_schema:
          type: object
          properties:
            P_COUNTRY:
              type: string
              description: "Country name (e.g., 'China', 'India', 'United States')"
          required: ["P_COUNTRY"]
    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generate charts from emissions data or regulatory analysis."

  tool_resources:
    regulations_search:
      name: "CLIMATE_ESG.SEARCH.ESG_REGULATIONS_SVC"
      max_results: "5"
      columns_and_descriptions:
        CONTENT:
          description: "Regulatory text with ESG requirements, thresholds, criteria"
          type: "string"
          searchable: true
          filterable: false
        FRAMEWORK:
          description: "Framework name: Paris Agreement, EU CSRD, TCFD, GHG Protocol, SBTi, EU Taxonomy, SEC Climate Rule, GRI Standards, Sector Thresholds, Climate Risk Assessment, Compliance Checklist"
          type: "string"
          searchable: false
          filterable: true
        SECTION:
          description: "Section within the framework"
          type: "string"
          searchable: false
          filterable: true
    filings_climate_search:
      name: "FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC"
      max_results: "5"
      columns_and_descriptions:
        CHUNK_TEXT:
          description: "SEC filing text including climate and environmental disclosures"
          type: "string"
          searchable: true
          filterable: false
        COMPANY_NAME:
          description: "Company name (e.g., EXXON MOBIL CORP, CHEVRON CORP, TESLA, INC.)"
          type: "string"
          searchable: false
          filterable: true
        ITEM_TITLE:
          description: "Filing section: Risk Factors, Business, MD&A, Legal Proceedings"
          type: "string"
          searchable: false
          filterable: true
        FISCAL_YEAR:
          description: "Fiscal year (2022-2025)"
          type: "string"
          searchable: false
          filterable: true
    get_country_emissions:
      identifier: CLIMATE_ESG.TOOLS.GET_COUNTRY_EMISSIONS
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    get_emissions_trend:
      identifier: CLIMATE_ESG.TOOLS.GET_EMISSIONS_TREND
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
  $$;

-- ============================================================
-- 6. EXAMPLE USAGE
-- ============================================================

-- Regulatory question:
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT',
--   $${"messages":[{"role":"user","content":[{"type":"text","text":"What are the EU CSRD requirements for transition plans?"}]}],"stream":false}$$);

-- Compliance assessment (multi-tool):
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT',
--   $${"messages":[{"role":"user","content":[{"type":"text","text":"Is China on track to meet Paris targets? Show emissions trend."}]}],"stream":false}$$);

-- Company disclosure analysis:
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN('CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT',
--   $${"messages":[{"role":"user","content":[{"type":"text","text":"What does ExxonMobil disclose about climate risks?"}]}],"stream":false}$$);
