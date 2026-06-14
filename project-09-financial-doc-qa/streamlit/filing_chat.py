import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Financial Document QA", layout="wide")
session = get_active_session()

st.title("Financial Document QA")
st.caption("Multi-turn Q&A over SEC 10-K/10-Q filings — powered by Cortex Search + Complete")

# Sidebar
st.sidebar.header("Settings")

# Company filter
companies = session.sql("""
    SELECT DISTINCT COMPANY_NAME FROM FINANCIAL_DOC_QA.STAGING.FILING_CHUNKS ORDER BY 1
""").to_pandas()["COMPANY_NAME"].tolist()
company_filter = st.sidebar.selectbox("Company filter (optional)", ["All companies"] + companies)
if company_filter == "All companies":
    company_filter = None

# Session management
if "session_id" not in st.session_state:
    st.session_state.session_id = None
    st.session_state.messages = []

if st.sidebar.button("New conversation"):
    st.session_state.session_id = None
    st.session_state.messages = []
    st.rerun()

if st.session_state.session_id:
    st.sidebar.info(f"Session: `{st.session_state.session_id[:8]}...`")

st.sidebar.divider()
st.sidebar.markdown("**Sample questions:**")
samples = [
    "What are Apple's main risk factors?",
    "What legal proceedings is Tesla facing?",
    "How does NVIDIA describe their AI strategy in MD&A?",
    "Compare Microsoft and Amazon's business descriptions",
]
for s in samples:
    if st.sidebar.button(s, key=s):
        st.session_state.pending_question = s

# Display history
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Handle input
prompt = st.chat_input("Ask about SEC filings...")
if hasattr(st.session_state, "pending_question"):
    prompt = st.session_state.pending_question
    del st.session_state.pending_question

if prompt:
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Searching SEC filings..."):
            # Escape single quotes
            q = prompt.replace("'", "''")
            sid = f"'{st.session_state.session_id}'" if st.session_state.session_id else "NULL"
            cf = f"'{company_filter}'" if company_filter else "NULL"

            result = session.sql(f"""
                CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('{q}', {sid}, {cf})
            """).collect()[0][0]

            # Extract session_id from conversation log if first turn
            if not st.session_state.session_id:
                latest = session.sql("""
                    SELECT SESSION_ID FROM FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG
                    ORDER BY CREATED_AT DESC LIMIT 1
                """).collect()
                if latest:
                    st.session_state.session_id = latest[0][0]

        st.markdown(result)

    st.session_state.messages.append({"role": "assistant", "content": result})
