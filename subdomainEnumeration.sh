#!/bin/bash

# Prompt user for the target domain
read -p "Enter the target domain: " TARGET

# Check if the domain is provided
if [ -z "$TARGET" ]; then
    echo "Error: No domain provided. Exiting."
    exit 1
fi

# Define output directory
OUTPUT_DIR="./recon"
mkdir -p "$OUTPUT_DIR"

# Subdomain Enumeration with subfinder
echo "[*] Starting Subdomain Enumeration with subfinder..."
subfinder -d "$TARGET" -o "$OUTPUT_DIR/subfinder_subdomains.txt"

# Subdomain Enumeration with bbot
echo "[*] Starting Subdomain Enumeration with bbot..."
BBOT_OUTPUT_DIR="./bbot_output"
bbot -t "$TARGET" -f subdomain-enum -o "$BBOT_OUTPUT_DIR"

# Copy subdomains.txt to the desired output directory
cp "$BBOT_OUTPUT_DIR/abnormal_susan/subdomains.txt" "$OUTPUT_DIR/bbot_subdomains.txt"

# Subdomain Enumeration with assetfinder
echo "[*] Starting Subdomain Enumeration with assetfinder..."
assetfinder --subs-only "$TARGET" > "$OUTPUT_DIR/assetfinder_subdomains.txt"

# Subdomain Enumeration with findomain
echo "[*] Starting Subdomain Enumeration with findomain..."
findomain -t "$TARGET" -u "$OUTPUT_DIR/findomain_subdomains.txt"

# Combining subdomain results from all tools
echo "[*] Combining subdomain results..."
cat "$OUTPUT_DIR"/*.txt | sort -u > "$OUTPUT_DIR/all_subdomains.txt"

echo "[*] Subdomain enumeration completed. Results saved in $OUTPUT_DIR/all_subdomains.txt"

