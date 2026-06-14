import streamlit as st
import json
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Market Research Agent", layout="wide")
session = get_active_session()

AGENT = "MARKET_RESEARCH.AGENT.MARKET_RESEARCH_AGENT"

st.title("Market Research Agent")
st.caption("Multi-tool AI agent combining financial analytics, earnings transcripts, SEC filings, and macro data")

# Sidebar
st.sidebar.header("Tools Available")
st.sidebar.markdown("""
- **sales_analytics** — Stock prices, trading volume
- **finance_analytics** — Economic indicators, SEC metrics
- **marketing_analytics** — Company profiles, industry data
- **earnings_search** — Earnings call transcripts (432K chunks)
- **filings_search** — SEC 10-K/10-Q sections (28K chunks)
- **get_macro_context** — World Bank/Fed Reserve indicators
- **data_to_chart** — Automatic visualizations
""")

if st.sidebar.button("Clear conversation"):
    st.session_state.messages = []
    st.experimental_rerun()

st.sidebar.divider()
st.sidebar.markdown("**Try these:**")
samples = [
    "What risks does NVIDIA disclose in their SEC filings?",
    "Compare Microsoft and Google's AI strategy",
    "What are current unemployment rates globally?",
    "Show Tesla's stock performance and legal proceedings",
]
for s in samples:
    if st.sidebar.button(s, key=s):
        st.session_state.pending_question = s
        st.experimental_rerun()

# State
if "messages" not in st.session_state:
    st.session_state.messages = []
if "pending_question" not in st.session_state:
    st.session_state.pending_question = ""

# Display history
for msg in st.session_state.messages:
    if msg["role"] == "user":
        st.markdown(f"**You:** {msg['content']}")
    else:
        st.markdown(f"**Agent:** {msg['content']}")
        if msg.get("tools_used"):
            with st.expander("Tools called"):
                for t in msg["tools_used"]:
                    st.markdown(f"- `{t}`")
    st.divider()

# Input
with st.form("question_form", clear_on_submit=True):
    user_input = st.text_input("Ask a market research question:", value=st.session_state.pending_question)
    submitted = st.form_submit_button("Submit")

if submitted and user_input:
    st.session_state.pending_question = ""
    st.session_state.messages.append({"role": "user", "content": user_input})

    with st.spinner("Researching across multiple data sources..."):
        prompt_escaped = user_input.replace("\\", "\\\\").replace('"', '\\"')
        payload = json.dumps({
            "messages": [{"role": "user", "content": [{"type": "text", "text": prompt_escaped}]}],
            "stream": False
        })

        result_raw = session.sql(f"""
            SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
                '{AGENT}',
                $${payload}$$,
                TRUE
            )
        """).collect()[0][0]

        response = json.loads(result_raw) if result_raw else {}
        content = response.get("content", [])

        answer_text = ""
        tools_used = []

        for item in content:
            item_type = item.get("type", "")
            if item_type == "text":
                answer_text += item.get("text", "")
            elif item_type == "tool_use":
                tool_info = item.get("tool_use", {})
                tools_used.append(tool_info.get("name", "unknown"))
            elif item_type == "tool_result":
                tool_info = item.get("tool_result", {})
                tools_used.append(tool_info.get("name", "unknown"))

        if not answer_text and "message" in response:
            answer_text = f"Error: {response['message']}"

    st.session_state.messages.append({
        "role": "assistant",
        "content": answer_text or "No response generated.",
        "tools_used": list(dict.fromkeys(tools_used))
    })
    st.experimental_rerun()
