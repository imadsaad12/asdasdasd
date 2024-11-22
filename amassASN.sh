#!/bin/bash

# Check if the ASN file parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <asn_file>"
  exit 1
fi

# Input file containing ASNs (one per line)
ASN_FILE="$1"

# Output file for unique domains
OUTPUT_FILE="asn-result.txt"

# Temporary file for storing intermediate results
TEMP_FILE="temp_domains.txt"

# Ensure the output file exists and is empty
> "$OUTPUT_FILE"

# Check if the input file exists
if [ ! -f "$ASN_FILE" ]; then
  echo "ASN file not found: $ASN_FILE"
  exit 1
fi

# Process each ASN in the input file
while IFS= read -r ASN; do
  # Skip empty lines or lines starting with a #
  if [ -z "$ASN" ] || [ "$(echo "$ASN" | cut -c1)" = "#" ]; then
    continue
  fi

  echo "Processing ASN: $ASN"

  # Remove "AS" prefix using sed
  CLEAN_ASN=$(echo "$ASN" | sed 's/^AS//')

  # Run Amass to get domains for the ASN
  amass intel -asn "$CLEAN_ASN" -o "$TEMP_FILE"

  # Append unique domains to the output file
  if [ -f "$TEMP_FILE" ]; then
    cat "$TEMP_FILE" >> "$OUTPUT_FILE"
  fi

done < "$ASN_FILE"

# Remove duplicates from the output file
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

# Clean up temporary file
rm -f "$TEMP_FILE"

echo "Domain enumeration completed. Results saved in: $OUTPUT_FILE"
