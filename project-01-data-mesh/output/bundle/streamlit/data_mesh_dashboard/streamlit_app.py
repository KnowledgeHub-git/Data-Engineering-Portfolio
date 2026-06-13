import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Data Mesh Dashboard", layout="wide")

session = get_active_session()

# Sidebar navigation
page = st.sidebar.radio("Navigation", [
    "Overview",
    "Data Products",
    "Governance",
    "Explorer"
])

# --- OVERVIEW ---
if page == "Overview":
    st.title("Data Mesh on Snowflake")

    st.markdown("""
    ## The Problem
    
    Most organizations start their data journey with a centralized data warehouse. A small platform team 
    owns everything — ingestion, transformations, quality, access. It works at first. But as the company 
    scales to dozens of domains, the central team becomes a bottleneck. Requests queue up. Context gets lost. 
    Data quality degrades because the people closest to the data don't own it.
    
    **Data Mesh** flips this model: treat data as a product, give ownership to domain teams, provide a 
    self-serve platform, and apply governance federally rather than centrally.
    
    This project implements that philosophy on Snowflake — end to end.
    """)

    st.divider()

    st.markdown("""
    ## What Was Built
    
    A production-grade data mesh across three business domains (**Sales**, **Finance**, **Marketing**), 
    each with full autonomy over their data lifecycle, backed by centralized governance that enforces 
    security and quality without creating bottlenecks.
    """)

    st.markdown("""
    ```
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                     MESH_GOVERNANCE (Central)                            │
    │   Tags · Masking Policies · Row Access · DMFs · Cortex Agent            │
    └──────────────────────────────┬──────────────────────────────────────────┘
                                   │ applies to all domains
          ┌────────────────────────┼────────────────────────┐
          ▼                        ▼                        ▼
    ┌─────────────┐         ┌─────────────┐         ┌─────────────┐
    │   SALES     │         │  FINANCE    │         │  MARKETING  │
    │   DOMAIN    │         │  DOMAIN     │         │  DOMAIN     │
    ├─────────────┤         ├─────────────┤         ├─────────────┤
    │ RAW (land)  │         │ RAW (land)  │         │ RAW (land)  │
    │  ↓ DT       │         │  ↓ DT       │         │  ↓ DT       │
    │ CURATED     │         │ CURATED     │         │ CURATED     │
    │  ↓ Views    │         │  ↓ Views    │         │  ↓ Views    │
    │ PRODUCTS    │         │ PRODUCTS    │         │ PRODUCTS    │
    └──────┬──────┘         └──────┬──────┘         └──────┬──────┘
           │                       │                       │
           └───────────────────────┼───────────────────────┘
                                   ▼
                    ┌───────────────────────────┐
                    │  Cortex Agent (NL Q&A)     │
                    │  Streamlit Dashboard       │
                    └───────────────────────────┘
    ```
    """)

    st.divider()

    st.markdown("## The Five Pillars")
    pillars = pd.DataFrame({
        "Pillar": [
            "Domain Ownership",
            "Data as Product",
            "Self-Serve Platform",
            "Federated Governance",
            "Semantic Layer"
        ],
        "What It Means": [
            "Each team owns their data end-to-end",
            "Data is discoverable, governed, and has an SLA",
            "Domain teams build pipelines without a central ticket",
            "Central policies, domain autonomy",
            "Business users query with intent, not SQL"
        ],
        "How It's Implemented": [
            "3 isolated databases, per-domain warehouses, OWNER/CONTRIBUTOR/READER roles",
            "Secure views in PRODUCTS schemas with descriptions and cross-domain grants",
            "8 Dynamic Tables with declarative SQL — no DAGs, no orchestration code",
            "Tags, masking policies, DMFs — defined once in MESH_GOVERNANCE, applied everywhere",
            "3 Semantic Views with verified queries + Cortex Agent for natural language"
        ]
    })
    st.dataframe(pillars, use_container_width=True)

    st.divider()

    st.markdown("## Live Infrastructure")
    col1, col2, col3, col4 = st.columns(4)

    dt_df = session.sql("""
        SELECT TABLE_CATALOG AS DATABASE_NAME, TABLE_SCHEMA AS SCHEMA_NAME,
               TABLE_NAME AS NAME, ROW_COUNT AS ROW_CNT, BYTES
        FROM SNOWFLAKE.INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE = 'DYNAMIC TABLE'
        ORDER BY TABLE_CATALOG, TABLE_NAME
    """).to_pandas()

    col1.metric("Business Domains", "3")
    col2.metric("Dynamic Tables", str(len(dt_df)))
    col3.metric("Semantic Views", "3")
    col4.metric("Governance Policies", "7")

    st.markdown("### Dynamic Table Health")
    st.caption("Self-serve pipelines — automatically refresh when source data changes. No scheduler needed.")
    st.dataframe(dt_df, use_container_width=True)

    st.divider()

    st.markdown("""
    ## How It Works
    
    **1. Domain Teams Own Their Data** — Each domain has a dedicated database with RAW → CURATED → PRODUCTS flow.
    
    **2. Data Flows Without Orchestration** — Dynamic Tables declare transformations in SQL. 
    Snowflake handles refresh automatically within the target lag (1 hour).
    
    **3. Governance Without Gatekeeping** — Masking policies enforce PII protection based on role. 
    A `SALES_READER` sees `***MASKED***` while `SALES_OWNER` sees real values. No code changes needed.
    
    **4. Cross-Domain Consumption** — Finance needs Sales data? Their OWNER role inherits SALES_READER 
    automatically. Zero-copy, governed access.
    
    **5. Natural Language Access** — The Cortex Agent routes questions to the right domain:
    - "Top stocks by price?" → Sales Analytics
    - "CPI trends?" → Finance Analytics  
    - "Companies by industry?" → Marketing Analytics
    """)

    st.divider()

    st.markdown("""
    ## Tech Stack
    
    | Component | Purpose |
    |-----------|---------|
    | Snowflake (AWS US West 2) | Core platform |
    | Dynamic Tables | Declarative ELT — no orchestrator needed |
    | Semantic Views | Business-level data model for NL queries |
    | Cortex Agent | Natural language Q&A across all domains |
    | Streamlit-in-Snowflake | This dashboard |
    | Snow CLI | Deployment automation |
    | Data Source | SNOWFLAKE_PUBLIC_DATA_FREE (370 real-world datasets) |
    """)

# --- DATA PRODUCTS ---
elif page == "Data Products":
    st.title("Data Products")

    st.markdown("""
    ## Role in the Data Mesh
    
    Each domain publishes governed, discoverable **data products** through the PRODUCTS schema. 
    Other domains consume these via cross-domain grants — zero-copy, governed, and always fresh.
    
    Data products are the **contract** between producer and consumer:
    - **Discoverable** — listed here with descriptions
    - **Governed** — masking policies enforce PII protection for readers
    - **Fresh** — backed by Dynamic Tables that auto-refresh from RAW
    - **Queryable** — accessible via SQL, Semantic Views, or the Cortex Agent
    
    ### How Cross-Domain Access Works
    
    ```
    FINANCE_OWNER role
      └── inherits SALES_READER
           └── can SELECT from SALES_DOMAIN.PRODUCTS.*
    
    No tickets. No data copies. Just role inheritance.
    ```
    """)

    st.divider()

    for domain in ["SALES_DOMAIN", "FINANCE_DOMAIN", "MARKETING_DOMAIN"]:
        domain_label = domain.replace("_DOMAIN", "")
        st.subheader(f"{domain_label} Domain Products")
        views_df = session.sql(f"""
            SELECT TABLE_NAME AS PRODUCT, COMMENT AS DESCRIPTION
            FROM {domain}.INFORMATION_SCHEMA.VIEWS 
            WHERE TABLE_SCHEMA = 'PRODUCTS'
            ORDER BY TABLE_NAME
        """).to_pandas()
        if not views_df.empty:
            st.dataframe(views_df, use_container_width=True)
        else:
            st.info("No published views yet.")

    st.divider()

    st.markdown("## Semantic Views (Natural Language Layer)")
    st.markdown("""
    These power the Cortex Agent — users ask questions in plain English and get SQL-backed answers.
    Each has 3 verified queries that improve accuracy on common questions.
    """)
    sem_df = pd.DataFrame({
        "Semantic View": ["SALES_ANALYTICS", "FINANCE_ANALYTICS", "MARKETING_ANALYTICS"],
        "Domain": ["Sales", "Finance", "Marketing"],
        "Covers": [
            "Stock prices, company directory, trading volume",
            "CPI, employment, GDP, SEC filings, financial institutions",
            "Digital presence (web domains), industry profiles, patents"
        ],
        "Verified Queries": [3, 3, 3]
    })
    st.dataframe(sem_df, use_container_width=True)

    st.divider()

    st.markdown("""
    ## Data Sources
    
    All data comes from `SNOWFLAKE_PUBLIC_DATA_FREE` — Snowflake's built-in free dataset:
    
    | Domain | Source | What It Contains |
    |--------|--------|-----------------|
    | Sales | COMPANY_INDEX | 10K companies with tickers, CIK, LEI, EIN |
    | Sales | STOCK_PRICE_TIMESERIES | Daily OHLCV for equities (2025+) |
    | Sales | SEC_13F_INDEX | Institutional investor holdings |
    | Finance | FINANCIAL_ECONOMIC_INDICATORS_TIMESERIES | CPI, GDP, employment, mortgage rates |
    | Finance | FINANCIAL_INSTITUTION_ENTITIES | 9.5K FDIC-regulated banks |
    | Finance | SEC_CORPORATE_REPORT_ATTRIBUTES | XBRL financial KPIs from 10-K/10-Q |
    | Marketing | USPTO_PATENT_INDEX | 10K patents with CPC classifications |
    | Marketing | COMPANY_DOMAIN_RELATIONSHIPS | 20K company-to-website mappings |
    | Marketing | COMPANY_CHARACTERISTICS | Industry, SIC, address, entity type |
    """)

# --- GOVERNANCE ---
elif page == "Governance":
    st.title("Federated Governance")

    st.markdown("""
    ## Role in the Data Mesh
    
    Governance is centralized in `MESH_GOVERNANCE` but applied **federally** across all domains. 
    This ensures consistent security and quality without bottlenecking domain teams.
    
    The governance layer provides:
    - **Classification Tags** — PII, SENSITIVITY, DOMAIN_OWNER, DATA_PRODUCT
    - **Dynamic Masking** — Columns auto-mask for READER roles (no code changes)
    - **Row Access Policies** — Domain isolation for shared tables
    - **Data Quality DMFs** — Automated freshness, completeness, and uniqueness checks
    
    ### The Key Insight
    
    Domain teams never interact with governance directly. They build their tables, and the 
    central MESH_ADMIN applies policies to them. If a column is tagged PII, it's masked for 
    readers automatically — no application changes, no deployment, no tickets.
    """)

    st.divider()

    st.markdown("## RBAC Hierarchy")
    st.markdown("""
    ```
    ACCOUNTADMIN
      └── MESH_ADMIN (tags, policies, DMFs, agent)
           ├── SALES_OWNER ──► SALES_CONTRIBUTOR ──► SALES_READER
           ├── FINANCE_OWNER ──► FINANCE_CONTRIBUTOR ──► FINANCE_READER
           └── MARKETING_OWNER ──► MARKETING_CONTRIBUTOR ──► MARKETING_READER
    
    Cross-domain: Each OWNER inherits other domains' READER roles
    Masking: READER sees ***MASKED*** | OWNER/CONTRIBUTOR sees real values
    ```
    
    | Role | Permissions |
    |------|------------|
    | OWNER | Full DDL, publish products, manage team |
    | CONTRIBUTOR | Write to RAW/CURATED, create dynamic tables |
    | READER | Read PRODUCTS only (masking enforced) |
    | MESH_ADMIN | Define tags, policies, DMFs, manage agent |
    """)

    st.divider()

    st.markdown("## Masking Policies")
    st.markdown("""
    | Policy | Behavior | Applied To |
    |--------|----------|-----------|
    | `MASK_PII` | Full mask: `***MASKED***` | EIN, Filing Manager, Address, ZIP, Employer ID |
    | `MASK_EMAIL` | Domain only: `***@domain.com` | URLs, web domains |
    | `MASK_PHONE` | Partial: `+1 ***..34` | Available (not currently applied) |
    """)

    st.divider()

    st.markdown("## PII Tags Applied")
    try:
        tag_df = session.sql("""
            SELECT 
                OBJECT_DATABASE, OBJECT_SCHEMA, OBJECT_NAME, COLUMN_NAME, TAG_VALUE
            FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
            WHERE TAG_NAME = 'PII' AND TAG_DATABASE = 'MESH_GOVERNANCE'
            ORDER BY OBJECT_DATABASE, OBJECT_NAME
        """).to_pandas()
        if not tag_df.empty:
            st.dataframe(tag_df, use_container_width=True)
        else:
            st.info("Tag references take up to 2 hours to appear in ACCOUNT_USAGE. Check back soon.")
    except Exception:
        st.info("Tag references not yet available (ACCOUNT_USAGE latency up to 2 hours).")

    st.divider()

    st.markdown("## Data Quality Monitoring (DMFs)")
    st.markdown("""
    DMFs are attached to all 9 RAW tables with `TRIGGER_ON_CHANGES` schedule:
    
    | DMF | What It Checks |
    |-----|---------------|
    | `DMF_NULL_RATE` | % of NULLs in critical columns |
    | `DMF_DUPLICATE_COUNT` | Duplicates on primary key columns |
    | `DMF_MAX_DATE` | Freshness (latest record date) |
    | `DMF_ROW_COUNT_CHECK` | Empty table detection |
    """)
    st.caption("Results appear below after data changes trigger the DMFs.")
    try:
        dq_df = session.sql("""
            SELECT TABLE_NAME, METRIC_NAME, VALUE, MEASUREMENT_TIME
            FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
            ORDER BY MEASUREMENT_TIME DESC
            LIMIT 20
        """).to_pandas()
        if not dq_df.empty:
            st.dataframe(dq_df, use_container_width=True)
        else:
            st.info("No DMF results yet — they run on next data change.")
    except Exception:
        st.info("DMF results not yet available.")

# --- EXPLORER ---
elif page == "Explorer":
    st.title("Cross-Domain Query Explorer")

    st.markdown("""
    ## Role in the Data Mesh
    
    The **semantic layer** enables any user to query structured data products using business 
    terminology. No need to know table schemas or write JOINs — the Semantic View handles it.
    
    The Cortex Agent uses these same Semantic Views to answer natural language questions, 
    routing to the right domain automatically based on the question's intent.
    
    ### How It Works
    
    ```sql
    -- Instead of knowing table schemas and writing JOINs:
    SELECT * FROM SEMANTIC_VIEW(
      SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS
      METRICS stock_prices.avg_close
      DIMENSIONS stock_prices.ticker
    )
    ```
    
    Select a domain below and run a query, or modify the SQL to explore freely.
    """)

    st.divider()

    sv_choice = st.selectbox("Select Semantic View", [
        "SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS",
        "FINANCE_DOMAIN.PRODUCTS.FINANCE_ANALYTICS",
        "MARKETING_DOMAIN.PRODUCTS.MARKETING_ANALYTICS"
    ])

    if sv_choice == "SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS":
        st.caption("Covers: stock prices, trading volume, company directory")
        query = st.text_area("SQL Query", value="""SELECT * FROM SEMANTIC_VIEW(
  SALES_DOMAIN.PRODUCTS.SALES_ANALYTICS
  METRICS stock_prices.avg_close, stock_prices.total_volume
  DIMENSIONS stock_prices.ticker, stock_prices.exchange
)
LIMIT 20""")
    elif sv_choice == "FINANCE_DOMAIN.PRODUCTS.FINANCE_ANALYTICS":
        st.caption("Covers: CPI, employment, GDP, SEC filings")
        query = st.text_area("SQL Query", value="""SELECT * FROM SEMANTIC_VIEW(
  FINANCE_DOMAIN.PRODUCTS.FINANCE_ANALYTICS
  METRICS metrics.avg_value
  DIMENSIONS metrics.variable_name, metrics.unit
)
LIMIT 20""")
    else:
        st.caption("Covers: industry profiles, digital presence, web domains")
        query = st.text_area("SQL Query", value="""SELECT * FROM SEMANTIC_VIEW(
  MARKETING_DOMAIN.PRODUCTS.MARKETING_ANALYTICS
  METRICS profiles.company_count
  DIMENSIONS profiles.industry, profiles.state
)
LIMIT 20""")

    if st.button("Run Query"):
        try:
            result_df = session.sql(query).to_pandas()
            st.dataframe(result_df, use_container_width=True)
            st.caption(f"{len(result_df)} rows returned")
        except Exception as e:
            st.error(f"Query error: {e}")

    st.divider()

    st.markdown("""
    ## Try These Questions with the Cortex Agent
    
    The Data Mesh Agent (`MESH_GOVERNANCE.APPS.DATA_MESH_AGENT`) understands all 3 domains:
    
    | Question | Routes To |
    |----------|-----------|
    | "What are the top 10 stocks by average closing price?" | Sales Analytics |
    | "Show total trading volume by exchange" | Sales Analytics |
    | "What is the average CPI value by unit?" | Finance Analytics |
    | "How many 10-K vs 10-Q filings are in the data?" | Finance Analytics |
    | "Which industries have the most companies?" | Marketing Analytics |
    | "What states have the most registered companies?" | Marketing Analytics |
    """)
