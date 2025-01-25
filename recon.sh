#!/bin/bash

# Dynamic Input via Command-Line Arguments or Environment Variables
DOMAINS_FILE="${1:-domains.txt}"                # List of domains (default: domains.txt)
SUBDOMAINS_WORDLIST="${2:-subdomains-wordlist.txt}"  # Subdomain wordlist (default: subdomains-wordlist.txt)
RESOLVERS_WORDLIST="${3:-resolvers-wordlist.txt}"    # Resolver list (default: resolvers-wordlist.txt)

# Output Files
ALL_SUBDOMAINS="subdomains.txt"
ALIVE_SUBDOMAINS="alive-subdomains.txt"
HTTPX_RESULTS="httpx.txt"
ALL_URLS="all_urls.txt"

# Start the enumeration process
echo "---- Subdomain Enumeration Started ----"

# Temporary directories for domain-specific results
TMP_DIR=$(mktemp -d)
PASSIVE_DIR="$TMP_DIR/passive"
ACTIVE_DIR="$TMP_DIR/active"

mkdir -p "$PASSIVE_DIR" "$ACTIVE_DIR"

# Loop through each domain
while IFS= read -r DOMAIN; do
  echo "Processing domain: $DOMAIN"

  # Passive Enumeration
  echo "---- Passive Enumeration for $DOMAIN ----"
  subfinder -d "$DOMAIN" >> "$PASSIVE_DIR/subfinder-$DOMAIN.txt"
  amass enum -d "$DOMAIN" --passive >> "$PASSIVE_DIR/amass-$DOMAIN.txt"
  echo "$DOMAIN" | assetfinder --subs-only | tee "$PASSIVE_DIR/assetfinder-$DOMAIN.txt"

  # Combine and deduplicate passive subdomains
  cat "$PASSIVE_DIR/subfinder-$DOMAIN.txt" "$PASSIVE_DIR/amass-$DOMAIN.txt" "$PASSIVE_DIR/assetfinder-$DOMAIN.txt"| sort -u | anew "$TMP_DIR/$DOMAIN-passive-subdomains.txt"

  # Active Enumeration
  echo "---- Active Enumeration for $DOMAIN ----"
  puredns bruteforce "$SUBDOMAINS_WORDLIST" "$DOMAIN" -r "$RESOLVERS_WORDLIST" -w "$ACTIVE_DIR/puredns-$DOMAIN.txt"

  # Alter subdomains
  cat "$TMP_DIR/$DOMAIN-passive-subdomains.txt" "$ACTIVE_DIR/puredns-$DOMAIN.txt" | sort -u | alterx | anew "$ACTIVE_DIR/alterx-$DOMAIN.txt"

  # Combine all active and passive subdomains
  cat "$TMP_DIR/$DOMAIN-passive-subdomains.txt" "$ACTIVE_DIR/alterx-$DOMAIN.txt" | sort -u | anew "$TMP_DIR/$DOMAIN-all-subdomains.txt"

  # Append to global subdomain file
  cat "$TMP_DIR/$DOMAIN-all-subdomains.txt" | anew "$ALL_SUBDOMAINS"

done < "$DOMAINS_FILE"

# Alive Subdomains Check
echo "---- Checking Alive Subdomains ----"
cat "$ALL_SUBDOMAINS" | /root/go/bin/httpx -sc 200 --title | anew "$ALIVE_SUBDOMAINS"

# Enumerate status codes, technology stack, and titles
echo "---- Enumerating HTTP Metadata ----"
cat "$ALL_SUBDOMAINS" | /root/go/bin/httpx -sc --title -td | anew "$HTTPX_RESULTS"

# Gather URLs using WaybackURLs
echo "---- Collecting URLs from Wayback Machine ----"
cat "$ALL_SUBDOMAINS" | waybackurls | anew "$ALL_URLS"

# Remove duplicates from final output files
echo "---- Removing duplicates from final outputs ----"
sort -u "$ALL_SUBDOMAINS" -o "$ALL_SUBDOMAINS"
sort -u "$ALIVE_SUBDOMAINS" -o "$ALIVE_SUBDOMAINS"
sort -u "$ALL_URLS" -o "$ALL_URLS"

echo "---- Enumeration Completed ----"
echo "Results saved in:"
echo "  - Subdomains: $ALL_SUBDOMAINS"
echo "  - Alive Subdomains: $ALIVE_SUBDOMAINS"
echo "  - HTTP Metadata: $HTTPX_RESULTS"
echo "  - Collected URLs: $ALL_URLS"
