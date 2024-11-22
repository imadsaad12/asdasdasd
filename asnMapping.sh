#!/bin/bash

# Function to fetch IP ranges for a given ASN using whois, mapcidr, and dnsx
get_domains_for_asn() {
    local asn=$1

    # Create a temporary file to store dnsx output
    tmp_file=$(mktemp)

    # Fetch IP ranges from whois, expand them with mapcidr, and resolve PTR records with dnsx
    whois -h whois.radb.net -- "-i origin $asn" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq | mapcidr -silent | dnsx -ptr -resp-only -silent > "$tmp_file"

    # Process the results from the temporary file
    while read -r ptr_record; do
        if [ $ptr_record ]; then
            # Extract the root domain from PTR records
            root_domain=$(echo $ptr_record | sed -E 's/.*\.([a-z0-9-]+\.[a-z]+)\.?/\1/')
            if [ $root_domain ]; then
                echo "$root_domain"
            fi
        fi
    done < "$tmp_file"

    # Delete the temporary file after processing
    rm -f "$tmp_file"
}

# Main script logic
asn_file=$1
output_file="asn-result.txt"

if [ -z "$asn_file" ]; then
    echo "Usage: $0 <ASN_FILE>"
    exit 1
fi

if [ ! -f "$asn_file" ]; then
    echo "File not found: $asn_file"
    exit 1
fi

# Create/clear the output file before writing
> "$output_file"

# Iterate through each ASN in the input file
while IFS= read -r asn; do
    echo "Processing ASN $asn..."
    
    # Get the domains for the current ASN and directly write to the output file if found
    domains=$(get_domains_for_asn "$asn")

    # Only append to the file if domains were found (check if output is not empty)
    if [ -n "$domains" ]; then
        echo "$domains" >> "$output_file"
    fi

    echo "-------------------------------------"
done < "$asn_file"

# Remove duplicates from the result file (sort + uniq)
sort -u "$output_file" -o "$output_file"

echo "Domains have been saved to $output_file."
