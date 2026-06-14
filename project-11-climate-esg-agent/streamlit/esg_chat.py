import streamlit as st
import json
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Climate ESG Compliance Agent", layout="wide")
session = get_active_session()

AGENT = "CLIMATE_ESG.AGENT.CLIMATE_ESG_AGENT"

st.title("Climate & ESG Compliance Agent")
st.caption("Regulatory compliance assessment combining ESG frameworks, emissions data, and corporate disclosures")

# Sidebar
st.sidebar.header("Frameworks Covered")
st.sidebar.markdown("""
- Paris Agreement (NDC, 1.5C pathway)
- EU CSRD / ESRS standards
- TCFD (4 pillars)
- GHG Protocol (Scope 1/2/3)
- SBTi (targets & validation)
- EU Taxonomy
- SEC Climate Rule
- GRI Standards
- Sector-specific thresholds
""")

if st.sidebar.button("Clear conversation"):
    st.session_state.messages = []
    st.experimental_rerun()

st.sidebar.divider()
st.sidebar.markdown("**Sample compliance questions:**")
samples = [
    "What are the TCFD governance disclosure requirements?",
    "Is China on track to meet Paris Agreement targets?",
    "What are the EU Taxonomy thresholds for steel?",
    "What does ExxonMobil disclose about climate risks?",
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
            with st.expander("Tools & sources"):
                for t in msg["tools_used"]:
                    st.markdown(f"- `{t}`")
    st.divider()

# Input
with st.form("question_form", clear_on_submit=True):
    user_input = st.text_input("Ask an ESG compliance question:", value=st.session_state.pending_question)
    submitted = st.form_submit_button("Submit")

if submitted and user_input:
    st.session_state.pending_question = ""
    st.session_state.messages.append({"role": "user", "content": user_input})

    with st.spinner("Analyzing compliance across frameworks and data..."):
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
