#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <domain_file>"
  exit 1
fi

# Input file containing domains
domain_file="$1"
output_file="all_subdomains.txt"

# Ensure the output file is empty before starting
> "$output_file"

# Iterate through each domain in the input file
while IFS= read -r domain; do

  echo "Running subdomain enumeration for $domain..."

  # Run Amass
  amass enum -passive -d "$domain" -o temp_subdomains.txt
  cat temp_subdomains.txt >> "$output_file"

  # Run Subfinder
  subfinder -d "$domain" -o temp_subdomains.txt
  cat temp_subdomains.txt >> "$output_file"

  # Run Findomain
  findomain -t "$domain" -u temp_subdomains.txt
  cat temp_subdomains.txt >> "$output_file"

  # Clear the temporary file after each domain
  rm temp_subdomains.txt

done < "$domain_file"

# Remove duplicates and sort the output file
sort -u "$output_file" -o "$output_file"

echo "Subdomain enumeration complete. Results saved in $output_file."
