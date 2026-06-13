import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Data Mesh Dashboard", layout="wide")

session = get_active_session()

# Sidebar navigation
page = st.sidebar.radio("Navigation", ["Overview", "Data Products", "Governance", "Explorer"])

# --- OVERVIEW ---
if page == "Overview":
    st.title("Data Mesh on Snowflake")
    st.markdown("""
    This project implements a **production-grade data mesh** on Snowflake, demonstrating how 
    independent business domains can own, govern, and share data as products — while maintaining 
    centralized governance and enabling natural language analytics.
    """)

    st.divider()

    # Architecture diagram using Mermaid
    st.subheader("Architecture")
    st.markdown("""
    ```
    ┌─────────────────────────────────────────────────────────────────────┐
    │                     MESH_GOVERNANCE (Central)                        │
    │   Tags · Masking Policies · Row Access · DMFs · Cortex Agent        │
    └──────────────────────────────┬──────────────────────────────────────┘
                                   │ applies to
          ┌────────────────────────┼────────────────────────┐
          ▼                        ▼                        ▼
    ┌─────────────┐         ┌─────────────┐         ┌─────────────┐
    │   SALES     │         │  FINANCE    │         │  MARKETING  │
    │   DOMAIN    │         │  DOMAIN     │         │  DOMAIN     │
    ├─────────────┤         ├─────────────┤         ├─────────────┤
    │ RAW         │         │ RAW         │         │ RAW         │
    │  ↓ DT       │         │  ↓ DT       │         │  ↓ DT       │
    │ CURATED     │         │ CURATED     │         │ CURATED     │
    │  ↓ Views    │         │  ↓ Views    │         │  ↓ Views    │
    │ PRODUCTS    │         │ PRODUCTS    │         │ PRODUCTS    │
    └──────┬──────┘         └──────┬──────┘         └──────┬──────┘
           │                       │                       │
           └───────────────────────┼───────────────────────┘
                                   ▼
                         Cortex Agent (NL Q&A)
                         Streamlit Dashboard
    ```
    """)

    st.divider()

    # Key pillars
    st.subheader("Five Pillars of Data Mesh")
    pillars = pd.DataFrame({
        "Pillar": [
            "Domain Ownership",
            "Data Products",
            "Self-Serve Platform",
            "Federated Governance",
            "Semantic Layer"
        ],
        "Implementation": [
            "3 databases with per-domain warehouses and OWNER/CONTRIBUTOR/READER roles",
            "Secure views in PRODUCTS schema, cross-domain SELECT grants",
            "8 Dynamic Tables with 1hr target lag — no orchestration code needed",
            "Central tags, masking policies, row access policies, and DMFs",
            "3 Semantic Views with verified queries + Cortex Agent for NL access"
        ]
    })
    st.dataframe(pillars, use_container_width=True)

    st.divider()

    # Live metrics
    st.subheader("Live Infrastructure Metrics")
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

    st.subheader("Dynamic Table Health")
    st.caption("Self-serve pipelines — automatically refresh when source data changes.")
    st.dataframe(dt_df, use_container_width=True)

# --- DATA PRODUCTS ---
elif page == "Data Products":
    st.title("Data Products")
    st.markdown("""
    **Role in the Data Mesh:** Each domain publishes governed, discoverable data products 
    through the PRODUCTS schema. Other domains consume these via cross-domain grants — 
    zero-copy, governed, and always fresh.
    
    Data products are the **contract** between producer and consumer. They are:
    - **Discoverable** — listed in the catalog with descriptions
    - **Governed** — masking policies enforce PII protection for readers
    - **Fresh** — backed by Dynamic Tables that auto-refresh from RAW
    - **Queryable** — accessible via SQL, Semantic Views, or the Cortex Agent
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
    st.subheader("Semantic Views (Natural Language Layer)")
    st.markdown("These power the Cortex Agent — ask questions in plain English.")
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

# --- GOVERNANCE ---
elif page == "Governance":
    st.title("Federated Governance")
    st.markdown("""
    **Role in the Data Mesh:** Governance is centralized in `MESH_GOVERNANCE` but applied 
    federally across all domains. This ensures consistent security and quality without 
    bottlenecking domain teams.
    
    The governance layer provides:
    - **Classification Tags** — PII, SENSITIVITY, DOMAIN_OWNER, DATA_PRODUCT
    - **Dynamic Masking** — Columns auto-mask for READER roles (no code changes needed)
    - **Row Access Policies** — Domain isolation for shared cross-domain tables
    - **Data Quality DMFs** — Automated freshness, completeness, and uniqueness checks
    """)

    st.divider()

    # RBAC diagram
    st.subheader("RBAC Hierarchy")
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
    """)

    st.divider()

    st.subheader("PII Tags Applied")
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
            st.info("Tag references may take up to 2 hours to appear in ACCOUNT_USAGE.")
    except Exception:
        st.info("Tag references not yet available (ACCOUNT_USAGE latency up to 2 hours).")

    st.subheader("Masking Policies")
    try:
        mask_df = session.sql("""
            SELECT POLICY_NAME, REF_DATABASE_NAME, REF_SCHEMA_NAME, 
                   REF_ENTITY_NAME, REF_COLUMN_NAME
            FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
            WHERE POLICY_KIND = 'MASKING_POLICY'
              AND POLICY_DATABASE = 'MESH_GOVERNANCE'
            ORDER BY REF_DATABASE_NAME
        """).to_pandas()
        if not mask_df.empty:
            st.dataframe(mask_df, use_container_width=True)
        else:
            st.info("Policy references may take up to 2 hours to appear in ACCOUNT_USAGE.")
    except Exception:
        st.info("Policy references not yet available (ACCOUNT_USAGE latency up to 2 hours).")

    st.subheader("Data Quality Monitoring (DMFs)")
    st.caption("DMFs run automatically when data changes. Results appear below after first trigger.")
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
    **Role in the Data Mesh:** The semantic layer enables any user to query structured 
    data products using business terminology. No need to know table schemas or write JOINs — 
    the Semantic View handles it.
    
    Select a domain below and run a query against its Semantic View, or modify the SQL to explore freely.
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
