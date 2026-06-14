import streamlit as st
import json
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Earnings Call RAG", layout="wide")
session = get_active_session()

SEARCH_SERVICE = "EARNINGS_RAG.SEARCH.EARNINGS_SEARCH_SVC"

st.title("Earnings Call RAG")
st.caption("Ask questions about earnings call transcripts — powered by Cortex Search + Complete")

# Sidebar
st.sidebar.header("Filters")
ticker_filter = st.sidebar.text_input("Ticker filter (optional)", placeholder="e.g., MSFT, AAPL")

if st.sidebar.button("Clear conversation"):
    st.session_state.messages = []
    st.experimental_rerun()

st.sidebar.divider()
st.sidebar.markdown("**Sample questions:**")
samples = [
    "What did Microsoft say about AI in recent earnings?",
    "How is NVIDIA's data center revenue growing?",
    "What guidance did Apple give for next quarter?",
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
        st.markdown(f"**Assistant:** {msg['content']}")
        if msg.get("sources"):
            with st.expander("Sources"):
                for src in msg["sources"]:
                    st.markdown(f"- **{src['ticker']}** | {src['event']} | {src['period']}")
    st.divider()

# Input
with st.form("question_form", clear_on_submit=True):
    user_input = st.text_input("Ask about earnings calls:", value=st.session_state.pending_question)
    submitted = st.form_submit_button("Submit")

if submitted and user_input:
    st.session_state.pending_question = ""
    st.session_state.messages.append({"role": "user", "content": user_input})

    with st.spinner("Searching transcripts..."):
        search_query = (ticker_filter + " " + user_input) if ticker_filter else user_input
        search_query_escaped = search_query.replace("'", "''").replace('"', '\\"')

        search_json = json.dumps({
            "query": search_query_escaped,
            "columns": ["CHUNK_TEXT", "TICKER", "COMPANY_NAME", "EVENT_TITLE", "FISCAL_PERIOD", "FISCAL_YEAR"],
            "limit": 5
        })

        results_raw = session.sql(f"""
            SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                '{SEARCH_SERVICE}',
                '{search_json.replace("'", "''")}'
            )
        """).collect()[0][0]

        results = json.loads(results_raw)
        chunks = results.get("results", [])

        context_parts = []
        sources = []
        for r in chunks:
            ticker = r.get("TICKER", "")
            event = r.get("EVENT_TITLE", "")
            period = f"{r.get('FISCAL_PERIOD', '')} {r.get('FISCAL_YEAR', '')}"
            text = r.get("CHUNK_TEXT", "")[:1000]
            context_parts.append(f"[{ticker} | {event} | {period}]\n{text}")
            sources.append({"ticker": ticker, "event": event, "period": period})

        context = "\n---\n".join(context_parts)

        rag_prompt = (
            "You are a financial analyst assistant. Answer based ONLY on the provided earnings call context. "
            "Cite the company ticker and event when referencing information.\n\n"
            f"## Context\n{context}\n\n"
            f"## Question\n{user_input}\n\nAnswer concisely with citations:"
        )

        answer = session.sql(f"""
            SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', $${rag_prompt}$$)
        """).collect()[0][0]

    st.session_state.messages.append({"role": "assistant", "content": answer, "sources": sources})
    st.experimental_rerun()
