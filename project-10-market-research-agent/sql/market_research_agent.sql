-- Project 10: Market Research Agent
-- Multi-tool Cortex Agent combining structured analytics, earnings search, SEC filings, and macro context

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS MARKET_RESEARCH
  COMMENT = 'Multi-tool market research agent combining structured analytics, earnings transcripts, SEC filings, and macro context';
CREATE SCHEMA IF NOT EXISTS MARKET_RESEARCH.AGENT;
CREATE SCHEMA IF NOT EXISTS MARKET_RESEARCH.TOOLS;
CREATE SCHEMA IF NOT EXISTS MARKET_RESEARCH.RESULTS;

-- ============================================================
-- 2. CUSTOM TOOL: Macro-Economic Context UDF
-- ============================================================

-- Joins ECON_VAULT Data Vault tables to return human-readable macro indicators
CREATE OR REPLACE FUNCTION MARKET_RESEARCH.TOOLS.GET_MACRO_CONTEXT(P_TOPIC VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  SELECT LISTAGG(INDICATOR_LINE, '\n') WITHIN GROUP (ORDER BY OBS_DATE DESC)
  FROM (
    SELECT DISTINCT
      s.VARIABLE_NAME || ' = ' || ROUND(p.VALUE, 4)::VARCHAR || ' ' || s.UNIT || ' (as of ' || p.OBSERVATION_DATE::VARCHAR || ', source: ' || p.RECORD_SOURCE || ')' AS INDICATOR_LINE,
      p.OBSERVATION_DATE AS OBS_DATE
    FROM ECON_VAULT.BUSINESS_VAULT.PIT_INDICATOR_LATEST p
    JOIN ECON_VAULT.RAW_VAULT.LINK_INDICATOR_GEOGRAPHY l ON p.LINK_HK = l.LINK_HK
    JOIN ECON_VAULT.RAW_VAULT.SAT_INDICATOR_DETAILS s ON l.INDICATOR_HK = s.INDICATOR_HK
    WHERE s.VARIABLE_NAME ILIKE '%' || P_TOPIC || '%'
    ORDER BY p.OBSERVATION_DATE DESC
    LIMIT 15
  )
$$;

-- ============================================================
-- 3. CORTEX AGENT (7 tools)
-- ============================================================

CREATE OR REPLACE AGENT MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT
  COMMENT = 'Multi-tool market research agent combining structured analytics, earnings transcripts, SEC filings, and macro context'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 16000

  instructions:
    response: "You are a senior market research analyst. Synthesize data from multiple sources to provide comprehensive, well-cited answers. Include specific numbers, dates, and sources. Structure responses with clear sections. Be concise but thorough."
    orchestration: "For quantitative financial data (stock prices, revenue, market cap) use sales_analytics. For economic indicators (CPI, GDP, employment) and SEC filings data use finance_analytics. For company profiles, industry classification, and digital presence use marketing_analytics. For qualitative insights from earnings calls (executive commentary, strategy, guidance) use earnings_search. For SEC filing details (risk factors, business overview, legal proceedings) use filings_search. For macro-economic context and current indicator values use get_macro_context. For complex questions, use multiple tools and synthesize findings. Always generate a chart when presenting numerical trends."
    sample_questions:
      - question: "Compare Microsoft and Google's AI strategy based on recent earnings and filings"
      - question: "What is NVIDIA's revenue trend and what risks do they disclose?"
      - question: "How has inflation impacted consumer goods companies' guidance?"
      - question: "Which tech companies are facing significant legal proceedings?"

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "sales_analytics"
        description: "Query stock prices, trading volume, company directories, and market performance from the Sales domain. Use for quantitative market data questions about stock performance and company financial metrics."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "finance_analytics"
        description: "Query economic indicators (CPI, unemployment, GDP), SEC corporate financial metrics (revenue, assets, liabilities), and fiscal calendar data from the Finance domain."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "marketing_analytics"
        description: "Query company industry profiles, web domains, patent counts, and geographic distribution from the Marketing domain. Use for company classification and competitive landscape questions."
    - tool_spec:
        type: "cortex_search"
        name: "earnings_search"
        description: "Search earnings call transcript paragraphs for qualitative insights - executive commentary, forward guidance, strategic priorities, competitive positioning. Covers 432K transcript chunks across thousands of companies."
    - tool_spec:
        type: "cortex_search"
        name: "filings_search"
        description: "Search SEC 10-K and 10-Q filing sections (Risk Factors, Business, MD&A, Legal Proceedings) for 49 major companies. Use for regulatory disclosures, risk analysis, and detailed financial narrative."
    - tool_spec:
        type: "generic"
        name: "get_macro_context"
        description: "Returns current macro-economic indicator values for a given topic keyword. Pass a keyword like 'inflation', 'CPI', 'unemployment', 'GDP', 'interest rate', or 'housing'. Returns formatted indicator names, values, and observation dates from World Bank and Federal Reserve sources."
        input_schema:
          type: object
          properties:
            P_TOPIC:
              type: string
              description: "Topic keyword to search for in macro-economic indicators (e.g., 'CPI', 'unemployment', 'GDP')"
          required: ["P_TOPIC"]
    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generate charts and visualizations from query results returned by other tools."

  tool_resources:
    sales_analytics:
      semantic_view: "SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS"
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    finance_analytics:
      semantic_view: "FINANCE_DOMAIN.PRODUCTS.FINANCE_ANALYTICS"
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    marketing_analytics:
      semantic_view: "MARKETING_DOMAIN.PRODUCTS.MARKETING_ANALYTICS"
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
    earnings_search:
      name: "EARNINGS_RAG.SEARCH.EARNINGS_SEARCH_SVC"
      max_results: "5"
      columns_and_descriptions:
        CHUNK_TEXT:
          description: "Transcript paragraph text from earnings calls"
          type: "string"
          searchable: true
          filterable: false
        TICKER:
          description: "Stock ticker symbol (e.g., MSFT, AAPL, GOOGL, NVDA, AMZN)"
          type: "string"
          searchable: false
          filterable: true
        COMPANY_NAME:
          description: "Full company name as it appears in filings"
          type: "string"
          searchable: false
          filterable: true
        FISCAL_YEAR:
          description: "Fiscal year of the earnings call (e.g., 2023, 2024, 2025)"
          type: "string"
          searchable: false
          filterable: true
    filings_search:
      name: "FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC"
      max_results: "5"
      columns_and_descriptions:
        CHUNK_TEXT:
          description: "SEC filing section text from 10-K and 10-Q reports"
          type: "string"
          searchable: true
          filterable: false
        COMPANY_NAME:
          description: "Company name as filed with SEC (e.g., APPLE INC., NVIDIA CORP, MICROSOFT CORP)"
          type: "string"
          searchable: false
          filterable: true
        ITEM_TITLE:
          description: "SEC filing section. Values: Risk Factors, Business, Management's Discussion and Analysis of Financial Condition and Results of Operations, Legal Proceedings, Controls and Procedures, Properties, Quantitative and Qualitative Disclosures About Market Risk"
          type: "string"
          searchable: false
          filterable: true
        FISCAL_YEAR:
          description: "Fiscal year of the filing (e.g., 2022, 2023, 2024, 2025)"
          type: "string"
          searchable: false
          filterable: true
    get_macro_context:
      identifier: MARKET_RESEARCH.TOOLS.GET_MACRO_CONTEXT
      type: function
      execution_environment:
        type: warehouse
        warehouse: "COMPUTE_WH"
  $$;

-- ============================================================
-- 4. EXAMPLE USAGE (via DATA_AGENT_RUN)
-- ============================================================

-- Single question (non-streaming):
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT',
--     $${ "messages": [{"role": "user", "content": [{"type": "text", "text": "What risks does NVIDIA disclose?"}]}], "stream": false }$$
-- );

-- With thread for multi-turn:
-- SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT',
--     $${ "messages": [{"role": "user", "content": [{"type": "text", "text": "Compare AI strategies of MSFT and GOOGL"}]}], "stream": false }$$,
--     TRUE
-- );
