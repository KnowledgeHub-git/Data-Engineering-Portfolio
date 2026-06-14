import streamlit as st
import json
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Real Estate Advisor", layout="wide")
session = get_active_session()

AGENT = "REAL_ESTATE.AGENT.RE_ADVISOR_AGENT"

st.title("Real Estate Investment Advisor")
st.caption("AI-powered location analysis combining house prices, mortgage rates, and disaster risk")

# Sidebar
st.sidebar.header("Tools")
st.sidebar.markdown("""
- **investment_knowledge** — RE fundamentals & metrics
- **get_state_hpi** — Freddie Mac House Price Index
- **get_mortgage_rates** — Current 30yr/15yr/ARM rates
- **get_disaster_risk** — FEMA disaster history by state
- **data_to_chart** — Visualizations
""")

mode = st.sidebar.radio("Mode", ["Chat", "Quick Compare"])

if st.sidebar.button("Clear conversation"):
    st.session_state.messages = []
    st.rerun()

st.sidebar.divider()
st.sidebar.markdown("**Try these:**")
samples = [
    "Compare California and Texas for real estate investment",
    "What are current mortgage rates?",
    "Which states have highest disaster risk?",
    "Explain the 1% rule for rental properties",
    "What's the HPI trend for Florida?",
]
for s in samples:
    if st.sidebar.button(s, key=s):
        st.session_state.pending_question = s


def call_agent(question):
    prompt_escaped = question.replace("\\", "\\\\").replace('"', '\\"')
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
            tools_used.append(item.get("tool_use", {}).get("name", ""))
        elif item_type == "tool_result":
            tools_used.append(item.get("tool_result", {}).get("name", ""))

    if not answer_text and "message" in response:
        answer_text = f"Error: {response['message']}"

    return answer_text, list(dict.fromkeys(tools_used))


# === CHAT MODE ===
if mode == "Chat":
    if "messages" not in st.session_state:
        st.session_state.messages = []

    for msg in st.session_state.messages:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])
            if msg.get("tools_used"):
                with st.expander("Tools called"):
                    for t in msg["tools_used"]:
                        st.markdown(f"- `{t}`")

    prompt = st.chat_input("Ask about real estate investment...")
    if hasattr(st.session_state, "pending_question"):
        prompt = st.session_state.pending_question
        del st.session_state.pending_question

    if prompt:
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        with st.chat_message("assistant"):
            with st.spinner("Analyzing markets and risk data..."):
                answer, tools = call_agent(prompt)

            st.markdown(answer or "No response generated.")
            if tools:
                with st.expander("Tools called"):
                    for t in tools:
                        st.markdown(f"- `{t}`")

        st.session_state.messages.append({
            "role": "assistant", "content": answer, "tools_used": tools
        })

# === COMPARISON MODE ===
elif mode == "Quick Compare":
    st.subheader("Side-by-Side State Comparison")

    col1, col2 = st.columns(2)
    with col1:
        state1 = st.text_input("State 1", value="California")
    with col2:
        state2 = st.text_input("State 2", value="Texas")

    if st.button("Compare", type="primary"):
        question = f"Compare {state1} and {state2} for real estate investment. Include house price trends, disaster risk, and your recommendation."

        with st.spinner(f"Comparing {state1} vs {state2}..."):
            answer, tools = call_agent(question)

        st.markdown(answer)
        if tools:
            with st.expander("Tools called"):
                for t in tools:
                    st.markdown(f"- `{t}`")
