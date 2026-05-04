#!/bin/bash

# --- DevOps Environment Inspection Script ---
# Goal: Verify system state for high-concurrency testing.

echo "--- System Resource Check ---"
# Check CPU and Memory usage (Process/System Inspection)
free -m
top -bn1 | head -n 5

echo -e "\n--- Network Connectivity Check ---"
# Check if internal services are reachable (Network Inspection)
# Using a common port like 8080 for your backend
ss -tuln | grep :8080 || echo "Port 8080 is currently idle."

echo -e "\n--- Log Directory Management ---"
# Filesystem navigation and directory creation
LOG_DIR="./logs"
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating missing log directory..."
    mkdir -p "$LOG_DIR"
fi

# Setting permissions: Owner can read/write, others can only read (Permissions Handling)
chmod 644 "$LOG_DIR"
echo "Permissions for $LOG_DIR updated to 644."

ls -ld "$LOG_DIR"