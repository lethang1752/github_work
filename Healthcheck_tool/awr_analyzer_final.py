import streamlit as st
from bs4 import BeautifulSoup
import re
import google.generativeai as genai
import pandas as pd
import sqlparse

# Set Streamlit page configuration
st.set_page_config(layout="wide", page_title="Oracle AWR/RAC Analyzer")

# Replace with your actual Gemini API key
GEMINI_API_KEY = "YOUR_GEMINI_API_KEY" 

try:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-2.0-flash')
except Exception as e:
    st.error(f"Failed to initialize Gemini AI: {e}")
    st.stop()

# Expanded topics to include RAC-specific sections
p_topics = [
    "Instance Efficiency Percentages (Target 100%)",
    "Top 10 Foreground Events by Total Wait Time",
    "Wait Classes by Total Wait Time",
    "IO Profile",
    "Global Cache and Enqueue Statistics Summary" # RAC Specific
]

h3_topics = [
    "SQL ordered by Elapsed Time",
    "SQL ordered by Elapsed Time (Global)", # RAC Specific
    "Complete List of SQL Text",
    "Buffer Pool Advisory",
    "PGA Memory Advisory",
    "SGA Target Advisory",
    "OS Statistics By Instance", # RAC Specific
    "Time Model"
]

h2_topics = ["ADDM Task ADDM"]
all_topics = p_topics + h3_topics + h2_topics

def analyze_with_gemini(content):
    prompt = f"Analyze the following Oracle AWR report section and identify performance bottlenecks or anomalies:\n\n{content}"
    response = model.generate_content(prompt)
    return response.text

def extract_section(soup, topic):
    """Finds the HTML content following a specific topic heading."""
    # Try to find the heading in various tags (P, H3, H2)
    heading = soup.find(lambda tag: tag.name in ["p", "h3", "h2", "th"] and topic in tag.get_text())
    if not heading:
        return None
    
    content = []
    for sibling in heading.find_next_siblings():
        if sibling.name in ["p", "h3", "h2", "hr"]: # Stop at next major section
            break
        content.append(str(sibling))
    return "".join(content)

def parse_awr_table(html_content):
    """Parses HTML tables into DataFrames, handling RAC 'I#' columns."""
    soup = BeautifulSoup(html_content, 'html.parser')
    table = soup.find('table')
    if not table:
        return None
    
    df = pd.read_html(str(table))[0]
    # Clean up column names (often multi-indexed in AWR)
    if isinstance(df.columns, pd.MultiIndex):
        df.columns = [' '.join(col).strip() for col in df.columns.values]
    return df

st.title("Oracle AWR & RAC Report Analyzer")
uploaded_file = st.file_uploader("Upload AWR HTML Report", type="html")

if uploaded_file:
    html_data = uploaded_file.read().decode("utf-8")
    soup = BeautifulSoup(html_data, 'html.parser')
    
    # Detect if it is a RAC report
    is_rac = "WORKLOAD REPOSITORY REPORT (RAC)" in soup.get_text()
    if is_rac:
        st.success("RAC Report Detected")
    else:
        st.info("Single-Node AWR Report Detected")

    selected_topic = st.selectbox("Select Section to Analyze", all_topics)
    content = extract_section(soup, selected_topic)

    if content:
        # Display raw content (Dataframe or HTML)
        df = parse_awr_table(content)
        if df is not None:
            st.dataframe(df, use_container_width=True)
        else:
            st.markdown(content, unsafe_allow_html=True)
        
        # Analyze with Gemini
        if st.button("Analyze with AI"):
            with st.spinner('Analyzing...'):
                analysis = analyze_with_gemini(content)
                st.markdown("### Gemini AI Analysis")
                st.markdown(analysis)
    else:
        st.warning(f"Topic '{selected_topic}' not found in this report.")