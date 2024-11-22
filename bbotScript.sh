#!/bin/bash

# Check if a file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Read each line from the input file and run the bbot command
while IFS= read -r line; do
    if [ ! -z "$line" ]; then  # Check if the line is not empty
        echo "Processing: $line"
        bbot -t "$line" -f subdomain-enum -o ./
    fi
done < "$1"
