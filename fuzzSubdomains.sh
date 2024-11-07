#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <subdomains_file> <wordlist>"
    exit 1
fi

# Assign input arguments to variables
SUBDOMAINS_FILE="$1"
WORDLIST="$2"

# Check if the subdomain file exists
if [[ ! -f "$SUBDOMAINS_FILE" ]]; then
    echo "Subdomains file '$SUBDOMAINS_FILE' not found!"
    exit 1
fi

# Check if the wordlist file exists
if [[ ! -f "$WORDLIST" ]]; then
    echo "Wordlist file '$WORDLIST' not found!"
    exit 1
fi

# Create a directory to store results, if it doesn't already exist
mkdir -p ffuf_results

# Loop through each subdomain in the subdomains file
while read -r SUBDOMAIN; do
    # Check if the line is empty
    if [[ -z "$SUBDOMAIN" ]]; then
        continue
    fi

    # Define the output file name for the subdomain
    OUTPUT_FILE="ffuf_results/${SUBDOMAIN}.txt"

    # Run ffuf for each subdomain and save the output in the respective file
    ffuf -u "${SUBDOMAIN}/FUZZ" -w "$WORDLIST" -o "$OUTPUT_FILE" -of md

    echo "Results for ${SUBDOMAIN} saved to ${OUTPUT_FILE}"
done < "$SUBDOMAINS_FILE"
