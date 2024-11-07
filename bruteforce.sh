#!/bin/bash

# Ensure all required inputs are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <subdomains_list.txt> <wordlist.txt> <output_file.txt>"
    exit 1
fi

# Assign input arguments
subdomains_list=$1
wordlist=$2
output=$3

# Create an empty temporary file to store generated subdomains
temp_file="tempe.txt"

# Generate new subdomains using the wordlist
while read -r subdomain; do
    echo "Generating subdomains for: $subdomain"

    # Clear the temporary file for new iteration
    > "$temp_file"

    # Loop through each word in the wordlist and generate subdomains
    while read -r word; do
        full_subdomain="$word.$subdomain"
        echo "$full_subdomain"
        echo "$full_subdomain" >> "$temp_file"
    done < "$wordlist"

    # Check for live subdomains using httpx and append to output file
    ./httpx -l "$temp_file" >> "$output"

    # Clear the temporary file for the next iteration
    > "$temp_file"

done < "$subdomains_list"

echo "Alive subdomains have been appended to $output"

