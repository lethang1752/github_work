import streamlit as st
from bs4 import BeautifulSoup
import re
import time
import os
import google.generativeai as genai
from google.api_core.exceptions import GoogleAPIError
import pandas as pd

# Set Streamlit page configuration to wide mode
st.set_page_config(layout="wide")

# Load GEMINI_API_KEY from environment variables
GEMINI_API_KEY = "AIzaSyAnaGmHU_c7L2lvyPgU-yPL55BOa3nM9Lw"  # Replace with your actual Gemini API key
# if not GEMINI_API_KEY:
#     st.error("GEMINI_API_KEY environment variable not set. Please set it and restart the app.")
#     st.stop()

# Configure Gemini AI client
try:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-2.0-flash')  # Assuming Gemini-2.0-flash is similar
except Exception as e:
    st.error(f"Failed to initialize Gemini AI: {e}")
    st.stop()

# Define topics categorized by their starting tags
p_topics = [
    "Instance Efficiency Percentages (Target 100%)",
    "Top 10 Foreground Events by Total Wait Time",
    "Wait Classes by Total Wait Time",
    "IO Profile"
]

h3_topics = [
    "SQL ordered by Elapsed Time",
    "Complete List of SQL Text",  # Added to handle SQL text extraction
    "Buffer Pool Advisory",
    "PGA Memory Advisory",
    "SGA Target Advisory"
]

h2_topics = [
    "ADDM Task ADDM"
]

all_topics = p_topics + h3_topics + h2_topics

# CSS for theme-adaptive table styling
APP_CSS = """
<style>
/* Base table styling */
table.tdiff {
    border-collapse: collapse;
    font-family: Roboto, sans-serif;
    font-size: 14px;
}

/* Header styling */
th.awrbg, th.awrnobg {
    font-family: Roboto, sans-serif;
    font-size: 16px;
    font-weight: bold;
    padding: 8px;
    border: 1px solid;
}

/* Cell styling */
td.awrnc, td.awrc, td.awrnclb, td.awrncbb, td.awrncrb, td.awrcrb, td.awrclb, td.awrcbb {
    font-family: Roboto, sans-serif;
    font-size: 14px;
    padding: 8px;
    border: 1px solid;
    vertical-align: top;
}

/* Light theme styling */
:root[data-theme="light"] table.tdiff,
@media (prefers-color-scheme: light) {
    table.tdiff {
        background-color: #ffffff;
    }
    th.awrbg, th.awrnobg {
        color: #000000;
        background-color: #f0f0f0;
        border-color: #333333;
    }
    td.awrnc, td.awrc, td.awrnclb, td.awrncbb, td.awrncrb, td.awrcrb, td.awrclb, td.awrcbb {
        color: #000000;
        border-color: #333333;
    }
}

/* Dark theme styling */
:root[data-theme="dark"] table.tdiff,
@media (prefers-color-scheme: dark) {
    table.tdiff {
        background-color: #1a1a1a;
    }
    th.awrbg, th.awrnobg {
        color: #ffffff;
        background-color: #333333;
        border-color: #ffffff;
    }
    td.awrnc, td.awrc, td.awrnclb, td.awrncbb, td.awrncrb, td.awrcrb, td.awrclb, td.awrcbb {
        color: #ffffff;
        border-color: #ffffff;
    }
}
</style>
"""

# Function to decode file with fallback encodings
def decode_file(file_content):
    encodings = ['utf-8', 'latin1', 'windows-1252']
    for encoding in encodings:
        try:
            return file_content.decode(encoding), encoding
        except UnicodeDecodeError:
            continue
    raise UnicodeDecodeError("Unable to decode file with UTF-8, Latin1, or Windows-1252 encodings.")

# Function to extract SQL text mapping
def extract_sql_text_mapping(soup):
    sql_text_map = {}
    h3 = soup.find('h3', class_='awr', string="Complete List of SQL Text")
    if h3:
        table = h3.find_next('table', class_='tdiff')
        if table:
            rows = table.find_all('tr')
            for row in rows[1:]:  # Skip header row
                cols = row.find_all('td')
                if len(cols) >= 2:
                    sql_id = cols[0].text.strip()
                    sql_text = cols[1].text.strip()
                    sql_text_map[sql_id] = sql_text
    return sql_text_map

# Function to extract SQL ordered by Elapsed Time data
def extract_sql_elapsed_time_data(table):
    sql_data = []
    rows = table.find_all('tr')
    if not rows or len(rows) < 2:  # Ensure there are rows and at least one data row
        st.warning("No data rows found in the 'SQL ordered by Elapsed Time' table.")
        return sql_data
    
    # Extract headers dynamically
    headers = [th.text.strip() for th in rows[0].find_all('th')]
    if not headers:
        st.warning("No headers found in the 'SQL ordered by Elapsed Time' table.")
        return sql_data
    
    # Debug: Print the headers to identify the exact names
    st.write("Debug - Headers in 'SQL ordered by Elapsed Time' table:", headers)
    
    # Define possible header variations for matching
    elapsed_time_headers = ['Elapsed Time per Exec (s)']
    executions_headers = ["Executions", "Exec #", "Execution Count", "Execs"]
    sql_id_headers = ["SQL Id", "SQL_ID", "SQLID"]
    percent_total_headers = ["%Total", "% Total"]
    percent_cpu_headers = ["%CPU", "% CPU"]
    percent_io_headers = ["%IO", "% IO"]
    
    # Find the index of each column based on possible header names
    elapsed_idx = next((i for i, h in enumerate(headers) if any(eh.lower() in h.lower() for eh in elapsed_time_headers)), None)
    exec_idx = next((i for i, h in enumerate(headers) if any(eh.lower() in h.lower() for eh in executions_headers)), None)
    sql_idx = next((i for i, h in enumerate(headers) if any(sh.lower() in h.lower() for sh in sql_id_headers)), None)
    percent_total_idx = next((i for i, h in enumerate(headers) if any(pt.lower() in h.lower() for pt in percent_total_headers)), None)
    percent_cpu_idx = next((i for i, h in enumerate(headers) if any(pc.lower() in h.lower() for pc in percent_cpu_headers)), None)
    percent_io_idx = next((i for i, h in enumerate(headers) if any(pi.lower() in h.lower() for pi in percent_io_headers)), None)
    
    # Validate required columns are found
    if sql_idx is None:
        st.warning("Could not find 'SQL Id' column in the table.")
        return sql_data
    
    # Extract data from subsequent rows
    for row in rows[1:]:  # Skip header row
        cols = row.find_all('td')
        if cols:
            sql_id = cols[sql_idx].text.strip() if sql_idx < len(cols) else ''
            elapsed_time = cols[elapsed_idx].text.strip() if elapsed_idx is not None and elapsed_idx < len(cols) else 'N/A'
            executions = cols[exec_idx].text.strip() if exec_idx is not None and exec_idx < len(cols) else 'N/A'
            percent_total = cols[percent_total_idx].text.strip() if percent_total_idx is not None and percent_total_idx < len(cols) else 'N/A'
            percent_cpu = cols[percent_cpu_idx].text.strip() if percent_cpu_idx is not None and percent_cpu_idx < len(cols) else 'N/A'
            percent_io = cols[percent_io_idx].text.strip() if percent_io_idx is not None and percent_io_idx < len(cols) else 'N/A'
            sql_data.append({
                'SQL_ID': sql_id,
                'Elapsed Time per Exec (s)': elapsed_time,
                'Executions': executions,
                '%Total': percent_total,
                '%CPU': percent_cpu,
                '%IO': percent_io
            })
    return sql_data

# Function to analyze SQL text with Gemini AI
def analyze_sql_with_gemini(sql_id, sql_text, metrics):
    try:
        time.sleep(2)  # Simulate processing delay
        prompt = f"""
        Analyze the following SQL query from an Oracle AWR report for performance issues and suggest optimizations. 
        Consider the following metrics in your analysis:
        - SQL_ID: {sql_id}
        - Elapsed Time per Exec: {metrics.get('Elapsed Time per Exec (s)', 'N/A')} seconds
        - Executions: {metrics.get('Executions', 'N/A')}
        - %Total: {metrics.get('%Total', 'N/A')}%
        - %CPU: {metrics.get('%CPU', 'N/A')}%
        - %IO: {metrics.get('%IO', 'N/A')}%

        SQL Text:
        {sql_text[:2000]}  # Truncate for API limits

        Structure the response with:
        - Summary of key metrics
        - Identified performance issues (consider CPU and IO contributions)
        - Recommendations for optimization (address high CPU or IO if applicable)
        """
        response = model.generate_content(prompt)
        return response.text
    except GoogleAPIError as e:
        return f"Error analyzing SQL_ID {sql_id} with Gemini AI: {e}"
    except Exception as e:
        return f"Unexpected error during SQL analysis for SQL_ID {sql_id}: {e}"

# Function to extract content for a given topic
def extract_content_for_topic(soup, topic):
    if topic in p_topics:
        for p in soup.find_all('p'):
            next_text = p.find_next(string=True).strip()
            if next_text == topic:
                table = p.find_next('table', class_='tdiff')
                if table:
                    return table.prettify(), True
                return None, False
    elif topic in h3_topics:
        h3 = soup.find('h3', class_='awr', string=topic)
        if h3:
            table = h3.find_next('table', class_='tdiff')
            if table:
                return table.prettify(), True
            return None, False
    elif topic in h2_topics:
        for h2 in soup.find_all('h2'):
            if h2.string and re.match(r'^ADDM Task ADDM.*$', h2.string.strip()):
                back_to_top = h2.find_next('a', class_='awr', href='#top', string='Back to Top')
                if back_to_top:
                    all_elements = []
                    current = h2
                    while current:
                        all_elements.append(str(current))
                        if current == back_to_top:
                            break
                        current = current.next_element
                    if all_elements:
                        content_html = ''.join(all_elements)
                        content_text = BeautifulSoup(content_html, 'html.parser').get_text(separator='\n', strip=True)
                        if content_text.strip():
                            return content_text, True
                return None, False
    return None, False

# Function to analyze table with Gemini AI (for p_topics and h3_topics, excluding SQL analysis)
def analyze_with_gemini(table_html):
    try:
        time.sleep(2)
        prompt = f"""
        Analyze the following table from an Oracle AWR report. Provide insights into performance issues, potential bottlenecks, and recommendations for optimization.

        Table HTML:
        {table_html[:2000]}

        Structure the response with:
        - Summary of key metrics
        - Identified issues
        - Recommendations
        """
        response = model.generate_content(prompt)
        return response.text
    except GoogleAPIError as e:
        return f"Error analyzing with Gemini AI: {e}"
    except Exception as e:
        return f"Unexpected error during analysis: {e}"

# Streamlit app
st.title("AWR Report Analyzer")
st.markdown("""
Upload an AWR HTML report and select a topic to analyze its corresponding table using Gemini-2.0-flash AI.
For 'SQL ordered by Elapsed Time', the app maps SQL_IDs to their full SQL text and analyzes each SQL statement.
""")

# Apply table CSS
st.markdown(APP_CSS, unsafe_allow_html=True)

# File uploader for AWR HTML
uploaded_file = st.file_uploader("Upload AWR HTML file", type="html")

if uploaded_file is not None:
    # Read and parse the HTML file with fallback decoding
    try:
        html, used_encoding = decode_file(uploaded_file.read())
        st.info(f"File decoded successfully using {used_encoding} encoding.")
        soup = BeautifulSoup(html, 'html.parser')
    except UnicodeDecodeError as e:
        st.error("Failed to decode the uploaded file. Please ensure the file is a valid HTML file encoded in UTF-8, Latin1, or Windows-1252.")
        st.stop()
    except Exception as e:
        st.error(f"Error processing the uploaded file: {e}")
        st.stop()
    
    # Extract content for all topics
    contents = {}
    topic_status = {}
    for topic in all_topics:
        content_html, found = extract_content_for_topic(soup, topic)
        contents[topic] = content_html
        topic_status[topic] = found
    
    # Extract SQL text mapping for "Complete List of SQL Text"
    sql_text_map = extract_sql_text_mapping(soup)
    if not sql_text_map:
        st.warning("Could not extract SQL text from 'Complete List of SQL Text'. Ensure the section exists in the AWR report.")
    
    # Dropdown to select topic
    selected_topic = st.selectbox("Select a topic to analyze", all_topics)
    
    # Display result for selected topic
    if selected_topic in contents and contents[selected_topic]:
        content = contents[selected_topic]
        st.markdown("### Extracted Content")
        if selected_topic == "ADDM Task ADDM":
            st.text(content)
        elif selected_topic == "SQL ordered by Elapsed Time":
            # Parse and display SQL ordered by Elapsed Time data
            table_soup = BeautifulSoup(content, 'html.parser')
            sql_data = extract_sql_elapsed_time_data(table_soup)
            
            if sql_data:
                # Display the full "SQL ordered by Elapsed Time" table
                st.markdown("#### SQL ordered by Elapsed Time Table")
                st.markdown(content, unsafe_allow_html=True)  # Render the original table
                
                # Create a summary table for SQL IDs
                st.markdown("#### Summary of SQL Statements")
                # Prepare data for the summary table
                summary_data = []
                for sql_entry in sql_data:
                    summary_data.append({
                        'SQL_ID': sql_entry['SQL_ID'],
                        'Elapsed Time per Exec (s)': sql_entry['Elapsed Time per Exec (s)'],
                        'Executions': sql_entry['Executions'],
                        '%Total': sql_entry['%Total'],
                        '%CPU': sql_entry['%CPU'],
                        '%IO': sql_entry['%IO']
                    })
                
                # Display summary table using Streamlit's dataframe
                df = pd.DataFrame(summary_data)
                st.dataframe(df, use_container_width=True)
                
                # Allow user to select a SQL ID for detailed analysis
                selected_sql_id = st.selectbox("Select a SQL_ID for detailed analysis", 
                                            options=[sql['SQL_ID'] for sql in sql_data],
                                            format_func=lambda x: f"{x}")
                
                # Display details for the selected SQL ID
                if selected_sql_id:
                    sql_entry = next(sql for sql in sql_data if sql['SQL_ID'] == selected_sql_id)
                    st.markdown(f"### Details for SQL_ID: {selected_sql_id}")
                    st.markdown(f"- **Elapsed Time per Exec (s)**: {sql_entry['Elapsed Time per Exec (s)']} seconds")
                    st.markdown(f"- **Executions**: {sql_entry['Executions']}")
                    st.markdown(f"- **%Total**: {sql_entry['%Total']}%")
                    st.markdown(f"- **%CPU**: {sql_entry['%CPU']}%")
                    st.markdown(f"- **%IO**: {sql_entry['%IO']}%")
                    
                    # Display full SQL text if available
                    sql_text = sql_text_map.get(selected_sql_id, "SQL text not found in 'Complete List of SQL Text'.")
                    st.markdown("**Full SQL Text:**")
                    st.code(sql_text, language='sql')
                    
                    # Analyze SQL text with Gemini AI
                    with st.spinner(f'Analyzing SQL_ID {selected_sql_id} with Gemini-2.0-flash...'):
                        analysis = analyze_sql_with_gemini(selected_sql_id, sql_text, sql_entry)
                        st.markdown("**Gemini AI Analysis:**")
                        st.markdown(analysis)
            else:
                st.warning("No SQL data extracted from 'SQL ordered by Elapsed Time' table.")
        else:
            # Render HTML for other topics
            render_html = f'<div class="extracted-content">{content}</div>'
            st.markdown(render_html, unsafe_allow_html=True)
            
            # Apply Gemini analysis for p_topics and h3_topics (excluding SQL ordered by Elapsed Time)
            if selected_topic in p_topics or (selected_topic in h3_topics and selected_topic != "SQL ordered by Elapsed Time" and selected_topic != "Complete List of SQL Text"):
                with st.spinner('Analyzing with Gemini-2.0-flash...'):
                    try:
                        analysis = analyze_with_gemini(content)
                        st.markdown("### Analysis Result")
                        st.markdown(analysis)
                    except Exception as e:
                        st.error(f"Error analyzing the topic: {e}")
    else:
        if topic_status.get(selected_topic, False):
            st.warning(f"Topic '{selected_topic}' found, but no content follows it in the AWR report.")
        else:
            st.warning(f"Topic '{selected_topic}' not found in the uploaded AWR report.")
else:
    st.info("Please upload an AWR HTML file to begin.")