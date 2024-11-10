#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 subdomains_file"
  exit 1
fi

# Input file
input_file="$1"

# Process subdomains: filter three-level subdomains and remove the first part
awk -F. 'NF == 4 {print $(NF-2) "." $(NF-1) "." $NF}' "$input_file" > processed_subdomains.txt

# Run the modified puredns command on the processed subdomains
#puredns bruteforce best-dns-wordlist.txt -d processed_subdomains.txt -r resolvers.txt -w 10 -t 2000 -r 1 -l 100 > results.txt
