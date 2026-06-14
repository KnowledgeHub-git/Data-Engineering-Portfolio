-- Project 09: Financial Document QA (multi-turn RAG over SEC 10-K/10-Q filings)
-- Credit-efficient: 28K chunks from 49 companies, ~5 LLM calls per demo session

-- ============================================================
-- 1. INFRASTRUCTURE
-- ============================================================

CREATE DATABASE IF NOT EXISTS FINANCIAL_DOC_QA
  COMMENT = 'SEC filing QA with Cortex Search + multi-turn RAG';
CREATE SCHEMA IF NOT EXISTS FINANCIAL_DOC_QA.STAGING;
CREATE SCHEMA IF NOT EXISTS FINANCIAL_DOC_QA.SEARCH;
CREATE SCHEMA IF NOT EXISTS FINANCIAL_DOC_QA.RESULTS;

-- ============================================================
-- 2. FILING CORPUS (49 companies, 7 section types, truncated to 30K chars)
-- ============================================================

CREATE OR REPLACE TABLE FINANCIAL_DOC_QA.STAGING.FILING_CORPUS AS
SELECT 
    s.CIK, s.COMPANY_NAME, s.ADSH, s.FORM_TYPE,
    s.ITEM_NUMBER, s.ITEM_TITLE, s.FISCAL_PERIOD, s.FISCAL_YEAR,
    s.FILED_DATE,
    LEFT(s.PLAINTEXT_CONTENT, 30000) AS SECTION_TEXT,
    LENGTH(LEFT(s.PLAINTEXT_CONTENT, 30000)) AS TEXT_LEN
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES s
WHERE s.FORM_TYPE IN ('10-K', '10-Q')
  AND s.PLAINTEXT_CONTENT IS NOT NULL
  AND LENGTH(s.PLAINTEXT_CONTENT) > 200
  AND s.ITEM_TITLE IN (
      'Risk Factors', 
      'Business',
      'Management''s Discussion and Analysis of Financial Condition and Results of Operations',
      'Legal Proceedings',
      'Controls and Procedures',
      'Properties',
      'Quantitative and Qualitative Disclosures About Market Risk'
  )
  AND s.CIK IN (
    -- Tech
    '0000320193', '0000789019', '0001318605', '0001045810', '0001652044', '0001018724',
    '0001326801', '0000858877', '0000804328', '0000002488', '0000050863',
    -- Finance
    '0000886982', '0000019617', '0001403161', '0000004962', '0000072971',
    -- Healthcare
    '0000078003', '0000200406', '0001551152', '0000097745', '0000885725',
    -- Consumer
    '0000021344', '0000829224', '0000077476', '0000354950', '0000909832',
    '0000080424', '0000764180', '0001585689', '0000818479', '0001365135',
    -- Industrial/Energy
    '0000034088', '0000093410', '0000012927', '0000037996', '0000066740',
    '0000049826', '0001064728', '0000040545', '0000310158', '0001090727',
    -- Other
    '0001467373', '0000051143', '0000731766', '0000732717', '0001413329',
    '0001324424', '0000047217', '0000060714', '0001114448'
  );

-- ============================================================
-- 3. CHUNKING (1500-char windows, 200-char overlap via 1300-step)
-- ============================================================

CREATE OR REPLACE TABLE FINANCIAL_DOC_QA.STAGING.FILING_CHUNKS AS
WITH numbered AS (
    SELECT 
        CIK, COMPANY_NAME, ADSH, FORM_TYPE, ITEM_NUMBER, ITEM_TITLE,
        FISCAL_PERIOD, FISCAL_YEAR, FILED_DATE, SECTION_TEXT, TEXT_LEN,
        CEIL(GREATEST(TEXT_LEN - 200, 1) / 1300.0)::INT AS NUM_CHUNKS
    FROM FINANCIAL_DOC_QA.STAGING.FILING_CORPUS
),
chunk_offsets AS (
    SELECT 
        n.CIK, n.COMPANY_NAME, n.ADSH, n.FORM_TYPE, n.ITEM_NUMBER, n.ITEM_TITLE,
        n.FISCAL_PERIOD, n.FISCAL_YEAR, n.FILED_DATE, n.SECTION_TEXT, n.TEXT_LEN,
        n.NUM_CHUNKS,
        ROW_NUMBER() OVER (PARTITION BY n.ADSH, n.ITEM_NUMBER ORDER BY seq.SEQ) - 1 AS CHUNK_IDX
    FROM numbered n
    JOIN (SELECT SEQ4() AS SEQ FROM TABLE(GENERATOR(ROWCOUNT => 25))) seq
      ON seq.SEQ < n.NUM_CHUNKS
)
SELECT 
    MD5(ADSH || ITEM_NUMBER || CHUNK_IDX::VARCHAR) AS CHUNK_ID,
    CIK, COMPANY_NAME, ADSH, FORM_TYPE, ITEM_TITLE,
    FISCAL_PERIOD, FISCAL_YEAR, FILED_DATE,
    CHUNK_IDX,
    SUBSTR(SECTION_TEXT, (CHUNK_IDX * 1300) + 1, 1500) AS CHUNK_TEXT,
    LENGTH(SUBSTR(SECTION_TEXT, (CHUNK_IDX * 1300) + 1, 1500)) AS CHUNK_LEN
FROM chunk_offsets
WHERE LENGTH(SUBSTR(SECTION_TEXT, (CHUNK_IDX * 1300) + 1, 1500)) > 50;

-- ============================================================
-- 4. CORTEX SEARCH SERVICE
-- ============================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC
  ON CHUNK_TEXT
  ATTRIBUTES COMPANY_NAME, FORM_TYPE, ITEM_TITLE, FISCAL_PERIOD, FISCAL_YEAR
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (SELECT CHUNK_ID, COMPANY_NAME, FORM_TYPE, ITEM_TITLE, 
             FISCAL_PERIOD, FISCAL_YEAR, FILED_DATE, CHUNK_TEXT
      FROM FINANCIAL_DOC_QA.STAGING.FILING_CHUNKS);

-- ============================================================
-- 5. RESULTS TABLES
-- ============================================================

CREATE OR REPLACE TABLE FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG (
    SESSION_ID VARCHAR,
    TURN_NUMBER INT,
    ROLE VARCHAR,
    MESSAGE VARCHAR,
    SOURCES VARIANT,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FINANCIAL_DOC_QA.RESULTS.SAMPLE_QA_RESULTS (
    QUESTION_ID INT AUTOINCREMENT,
    SESSION_ID VARCHAR,
    QUESTION VARCHAR,
    ANSWER VARCHAR,
    SOURCE_COMPANY_1 VARCHAR,
    SOURCE_SECTION_1 VARCHAR,
    SOURCE_PERIOD_1 VARCHAR,
    SOURCE_COMPANY_2 VARCHAR,
    SOURCE_SECTION_2 VARCHAR,
    SOURCE_PERIOD_2 VARCHAR,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 6. MULTI-TURN QA STORED PROCEDURE
-- ============================================================

CREATE OR REPLACE PROCEDURE FINANCIAL_DOC_QA.RESULTS.ASK_FILING(
    P_QUESTION VARCHAR,
    P_SESSION_ID VARCHAR DEFAULT NULL,
    P_COMPANY_FILTER VARCHAR DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE
    v_session VARCHAR;
    v_turn INT;
    v_history VARCHAR DEFAULT '';
    v_context VARCHAR DEFAULT '';
    v_prompt VARCHAR;
    v_answer VARCHAR;
    v_search_json VARCHAR;
    v_raw_results VARCHAR;
BEGIN
    v_session := COALESCE(:P_SESSION_ID, UUID_STRING());
    
    -- Get current turn number
    SELECT COALESCE(MAX(TURN_NUMBER), 0) + 1 INTO v_turn
    FROM FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG
    WHERE SESSION_ID = :v_session;
    
    -- Get conversation history (last 6 messages = 3 turns)
    SELECT COALESCE(LISTAGG(ROLE || ': ' || LEFT(MESSAGE, 500), '\n') WITHIN GROUP (ORDER BY TURN_NUMBER), '') INTO v_history
    FROM (
        SELECT ROLE, MESSAGE, TURN_NUMBER
        FROM FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG
        WHERE SESSION_ID = :v_session
        ORDER BY TURN_NUMBER DESC
        LIMIT 6
    );
    
    -- Build search query JSON
    LET search_text VARCHAR := COALESCE(:P_COMPANY_FILTER || ' ', '') || :P_QUESTION;
    v_search_json := '{"query":"' || REPLACE(REPLACE(:search_text, '"', '\\"'), '\n', ' ') || '","columns":["CHUNK_TEXT","COMPANY_NAME","ITEM_TITLE","FISCAL_PERIOD","FISCAL_YEAR"],"limit":5}';
    
    -- Execute search
    SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'FINANCIAL_DOC_QA.SEARCH.FILING_SEARCH_SVC',
        :v_search_json
    ) INTO v_raw_results;
    
    -- Build context from results
    SELECT COALESCE(LISTAGG(
        '[' || r.VALUE:COMPANY_NAME::VARCHAR || ' | ' || 
        r.VALUE:ITEM_TITLE::VARCHAR || ' | ' || 
        r.VALUE:FISCAL_PERIOD::VARCHAR || ' ' || r.VALUE:FISCAL_YEAR::VARCHAR || ']\n' ||
        LEFT(r.VALUE:CHUNK_TEXT::VARCHAR, 1200), '\n---\n'
    ) WITHIN GROUP (ORDER BY r.INDEX), 'No context found.') INTO v_context
    FROM TABLE(FLATTEN(input => PARSE_JSON(:v_raw_results):results)) r;
    
    -- Build RAG prompt
    v_prompt := 'You are a financial analyst assistant answering questions about SEC filings (10-K and 10-Q reports). ' ||
        'Use ONLY the provided context to answer. Cite the company name and filing section. ' ||
        'If the context is insufficient, say so.\n\n';
    
    IF (LENGTH(v_history) > 0) THEN
        v_prompt := v_prompt || '## Prior Conversation\n' || v_history || '\n\n';
    END IF;
    
    v_prompt := v_prompt || '## SEC Filing Context\n' || v_context || '\n\n';
    v_prompt := v_prompt || '## Question\n' || :P_QUESTION || '\n\nAnswer with citations:';
    
    -- LLM call
    SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', LEFT(:v_prompt, 15000)) INTO v_answer;
    
    -- Log user message
    INSERT INTO FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG (SESSION_ID, TURN_NUMBER, ROLE, MESSAGE, SOURCES)
    VALUES (:v_session, :v_turn, 'user', :P_QUESTION, NULL);
    
    -- Log assistant response
    INSERT INTO FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG (SESSION_ID, TURN_NUMBER, ROLE, MESSAGE, SOURCES)
    SELECT :v_session, :v_turn + 1, 'assistant', :v_answer, PARSE_JSON(:v_raw_results):results;
    
    RETURN v_answer;
END;

-- ============================================================
-- 7. EXAMPLE USAGE
-- ============================================================

-- Single question:
-- CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('What are Apple''s main risk factors?', NULL, 'APPLE');

-- Multi-turn conversation (reuse session_id):
-- CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('What legal proceedings is Tesla facing?', 'my-session', 'TESLA');
-- CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('How do those compare to their risk disclosures?', 'my-session', 'TESLA');

-- Cross-company:
-- CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('Compare AI strategies of Microsoft and NVIDIA', NULL, NULL);
