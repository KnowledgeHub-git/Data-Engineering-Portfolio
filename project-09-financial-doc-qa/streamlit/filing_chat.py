import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Financial Document QA", layout="wide")
session = get_active_session()

st.title("Financial Document QA")
st.caption("Multi-turn Q&A over SEC 10-K/10-Q filings — powered by Cortex Search + Complete")

# Sidebar
st.sidebar.header("Settings")

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
if "pending_question" not in st.session_state:
    st.session_state.pending_question = ""

if st.sidebar.button("New conversation"):
    st.session_state.session_id = None
    st.session_state.messages = []
    st.experimental_rerun()

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
        st.experimental_rerun()

# Display history
for msg in st.session_state.messages:
    if msg["role"] == "user":
        st.markdown(f"**You:** {msg['content']}")
    else:
        st.markdown(f"**Assistant:** {msg['content']}")
    st.divider()

# Input
with st.form("question_form", clear_on_submit=True):
    user_input = st.text_input("Ask about SEC filings:", value=st.session_state.pending_question)
    submitted = st.form_submit_button("Submit")

if submitted and user_input:
    st.session_state.pending_question = ""
    st.session_state.messages.append({"role": "user", "content": user_input})

    with st.spinner("Searching SEC filings..."):
        q = user_input.replace("'", "''")
        sid = f"'{st.session_state.session_id}'" if st.session_state.session_id else "NULL"
        cf = f"'{company_filter}'" if company_filter else "NULL"

        result = session.sql(f"""
            CALL FINANCIAL_DOC_QA.RESULTS.ASK_FILING('{q}', {sid}, {cf})
        """).collect()[0][0]

        if not st.session_state.session_id:
            latest = session.sql("""
                SELECT SESSION_ID FROM FINANCIAL_DOC_QA.RESULTS.CONVERSATION_LOG
                ORDER BY CREATED_AT DESC LIMIT 1
            """).collect()
            if latest:
                st.session_state.session_id = latest[0][0]

    st.session_state.messages.append({"role": "assistant", "content": result})
    st.experimental_rerun()
