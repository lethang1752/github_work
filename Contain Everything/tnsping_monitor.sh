#!/bin/bash

# Output Example
# Starting tnsping monitoring
# From: node1 to node2
# Duration: 5 days
# Checking every: 30 seconds
# Threshold: 100 ms
# ---------------------------------------------
# 2025-04-03 10:00:00 - Response time: 45 ms
# 2025-04-03 10:00:30 - Response time: 150 ms
# WARNING: High latency detected! Response time 150 ms exceeds threshold of 100 ms
# ----------------------------------------
# 2025-04-03 10:01:00 - Response time: 60 ms 

# Variable Export

# Configuration
SOURCE_NODE="node1"          # Replace with your source node
TARGET_NODE="node2"          # Replace with your target node
TNS_SERVICE="your_service_name"  # Replace with your TNS service name
DURATION=$((5 * 24 * 60 * 60))  # 5 days in seconds
CHECK_INTERVAL=30           # Check every 30 seconds
THRESHOLD=100               # Threshold in milliseconds

echo "Starting tnsping monitoring"
echo "From: $SOURCE_NODE to $TARGET_NODE"
echo "Duration: 5 days"
echo "Checking every: $CHECK_INTERVAL seconds"
echo "Threshold: $THRESHOLD ms"
echo "---------------------------------------------"

# Calculate end time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))

while [ $(date +%s) -lt $END_TIME ]; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Run tnsping and extract time
    RESULT=$(tnsping $TNS_SERVICE 2>/dev/null)
    TIME=$(echo "$RESULT" | grep -o '[0-9]\+ msec' | awk '{print $1}')
    
    # Handle case where tnsping fails or no time is found
    if [ -z "$TIME" ]; then
        echo "$TIMESTAMP - Error: tnsping failed or no response. Output: $RESULT"
        sleep $CHECK_INTERVAL
        continue
    fi
    
    # Print result
    echo "$TIMESTAMP - Response time: $TIME ms"
    
    # Check if time exceeds threshold
    if [ "$TIME" -gt $THRESHOLD ]; then
        echo "WARNING: High latency detected! Response time $TIME ms exceeds threshold of $THRESHOLD ms"
        echo "----------------------------------------"
    fi
    
    # Wait for next check
    sleep $CHECK_INTERVAL
done

echo "Monitoring completed after 5 days"