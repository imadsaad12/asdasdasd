#!/bin/bash

# Ensure required tools are installed
# if ! command -v katana &> /dev/null; then
#     echo "Katana could not be found. Please install Katana to proceed."
#     exit 1
# fi

# if ! command -v gau &> /dev/null; then
#     echo "GAU could not be found. Please install GAU to proceed."
#     exit 1
# fi

# if ! command -v waybackurls &> /dev/null; then
#     echo "Waybackurls could not be found. Please install Waybackurls to proceed."
#     exit 1
# fi

# Input file
SUBDOMAIN_FILE="httpx.txt"
OUTPUT_FILE="all_urls.txt"

# Check if the subdomain file exists
if [ ! -f "$SUBDOMAIN_FILE" ]; then
    echo "Subdomain file $SUBDOMAIN_FILE not found!"
    exit 1
fi

# Initialize or clear the output file
> $OUTPUT_FILE

# Function to gather URLs using Katana, GAU, and WaybackURLs
gather_urls() {
    local subdomain=$1
    echo "Gathering URLs for: $subdomain"
    
    # Run Katana
    # katana -u "https://$subdomain" -o katana_urls.txt
    # cat katana_urls.txt >> $OUTPUT_FILE
    # rm katana_urls.txt

    # Run GAU
   # gau "$subdomain" > gau_urls.txt
    #cat gau_urls.txt >> $OUTPUT_FILE
    #rm gau_urls.txt

    # Run WaybackURLs
    echo "$subdomain" | waybackurls > wayback_urls.txt
    cat wayback_urls.txt >> $OUTPUT_FILE
    rm wayback_urls.txt
}

# Run the function for each subdomain
while IFS= read -r subdomain; do
    gather_urls "$subdomain"
done < "$SUBDOMAIN_FILE"

# Remove duplicate URLs
sort -u $OUTPUT_FILE -o $OUTPUT_FILE

echo "[*] URL gathering completed. All URLs are saved in $OUTPUT_FILE"
