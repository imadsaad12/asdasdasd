#!/bin/bash

# Check if required tools are installed
if ! command -v rush &> /dev/null; then
    echo "rush could not be found. Please install rush to proceed."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "Python3 could not be found. Please install Python3 to proceed."
    exit 1
fi

# Check if LinkFinder is installed
if [ ! -f "/home/linkfinder.py" ]; then
    echo "linkfinder.py script not found at /home/linkfinder.py! Please ensure it is in the correct location."
    exit 1
fi

# Check if the input file exists
URLS_FILE="urls.txt"
OUTPUT_FILE="wordlist.txt"
TEMP_FILE="temp_output.txt"

if [ ! -f "$URLS_FILE" ]; then
    echo "URLs file $URLS_FILE not found!"
    exit 1
fi

# Initialize or clear the output files
> $OUTPUT_FILE
> $TEMP_FILE

# Run LinkFinder on each URL in parallel using rush
cat $URLS_FILE | rush -j10 "python3 /home/linkfinder.py -o cli -i {} >> $TEMP_FILE"

# Sort and remove duplicate URLs
sort -u $TEMP_FILE -o $OUTPUT_FILE

# Clean up temporary file
rm $TEMP_FILE

echo "[*] URL analysis completed. Unique URLs are saved in $OUTPUT_FILE"
