#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ip_file> <subdomain_file>"
    exit 1
fi

# Input files
IP_FILE=$1
SUBDOMAIN_FILE=$2

# Check if input files exist
if [ ! -f "$IP_FILE" ]; then
    echo "IP file $IP_FILE not found!"
    exit 1
fi

if [ ! -f "$SUBDOMAIN_FILE" ]; then
    echo "Subdomain file $SUBDOMAIN_FILE not found!"
    exit 1
fi

# Perform virtual host fuzzing for each IP
while IFS= read -r ip; do
    echo "Fuzzing IP: $ip"
    ffuf -w "$SUBDOMAIN_FILE" -u https://$ip -H "Host: FUZZ" -of csv -o "${ip}.csv"
done < "$IP_FILE"

echo "[*] Fuzzing completed. Results saved in CSV files for each IP."
