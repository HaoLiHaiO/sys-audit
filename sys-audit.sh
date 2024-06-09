#!/bin/bash

# Define output file
OUTPUT_FILE="system_audit_$(date +%Y%m%d_%H%M%S).log"

echo "Starting System Audit..." | tee -a $OUTPUT_FILE

# System Information
echo "Gathering System Information..." | tee -a $OUTPUT_FILE
hostname | tee -a $OUTPUT_FILE
uname -a | tee -a $OUTPUT_FILE
cat /etc/os-release | tee -a $OUTPUT_FILE

# Disk Usage
echo "Checking Disk Usage..." | tee -a $OUTPUT_FILE
df -h | tee -a $OUTPUT_FILE

# Packages
echo "Listing Installed Packages..." | tee -a $OUTPUT_FILE

detect_package_manager() {
    if command -v dpkg &> /dev/null; then
        echo "dpkg"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v rpm &> /dev/null; then
        echo "rpm"
    else
        echo "unknown"
    fi
}

PACKAGE_MANAGER=$(detect_package_manager)

case $PACKAGE_MANAGER in
    dpkg)
        dpkg -l | tee -a $OUTPUT_FILE
        ;;
    pacman)
        pacman -Q | tee -a $OUTPUT_FILE
        ;;
    rpm)
        rpm -qa | tee -a $OUTPUT_FILE
        ;;
    *)
        echo "Unsupported package manager" | tee -a $OUTPUT_FILE
        ;;
esac

# Network Information
echo "Gathering Network Information..." | tee -a $OUTPUT_FILE
ip address | tee -a $OUTPUT_FILE
ss -plants | tee -a $OUTPUT_FILE

# Open Ports
echo "Checking Open Ports..." | tee -a $OUTPUT_FILE
lsof -i -P -n | grep LISTEN | tee -a $OUTPUT_FILE

# Active Connections
echo "Listing Active Connections..." | tee -a $OUTPUT_FILE
ss -tunap | tee -a $OUTPUT_FILE

# Users and Groups
echo "Listing Users and Groups..." | tee -a $OUTPUT_FILE
cat /etc/passwd | tee -a $OUTPUT_FILE
cat /etc/group | tee -a $OUTPUT_FILE

# Scheduled Tasks
echo "Listing Scheduled Tasks..." | tee -a $OUTPUT_FILE
crontab -l | tee -a $OUTPUT_FILE
ls /etc/cron.* | tee -a $OUTPUT_FILE

# File System Tree
echo "Generating File System Tree..." | tee -a $OUTPUT_FILE
tree / -L 2 | tee -a $OUTPUT_FILE

echo "System Audit Completed. Results saved in $OUTPUT_FILE"