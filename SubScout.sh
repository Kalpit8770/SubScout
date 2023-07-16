#!/bin/bash

# Color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

echo -e "${YELLOW}"
echo "   _____       _     _____                 _   "
echo "  / ____|     | |   / ____|               | |  "
echo " | (___  _   _| |__| (___   ___ ___  _   _| |_ "
echo "  \___ \| | | | '_ \\___ \ / __/ _ \| | | | __|"
echo "  ____) | |_| | |_) |___) | (_| (_) | |_| | |_ "
echo " |_____/ \__,_|_.__/_____/ \___\___/ \__,_|\__|"
echo -e "${RESET}"

# Check if required tools are installed
command -v amass >/dev/null 2>&1 || { echo -e "${RED}Amass is not installed. Please install it (https://github.com/OWASP/Amass) and try again.${RESET}"; exit 1; }
command -v subfinder >/dev/null 2>&1 || { echo -e "${RED}Subfinder is not installed. Please install it (https://github.com/projectdiscovery/subfinder) and try again.${RESET}"; exit 1; }
command -v assetfinder >/dev/null 2>&1 || { echo -e "${RED}Assetfinder is not installed. Please install it (https://github.com/tomnomnom/assetfinder) and try again.${RESET}"; exit 1; }

# Check if the domain argument is provided
if [[ -z "$1" ]]; then
    echo -e "${YELLOW}Usage: $0 <domain>${RESET}"
    exit 1
fi

domain=$1

# Create a timestamped directory to store the results
results_dir="$domain-$(date +%Y%m%d%H%M%S)"
mkdir "$results_dir"
cd "$results_dir" || exit

echo -e "${GREEN}[*] Enumerating subdomains using Amass...${RESET}"
amass enum -d "$domain" -o amass.txt

echo -e "${GREEN}[*] Enumerating subdomains using Subfinder...${RESET}"
subfinder -d "$domain" -o subfinder.txt

echo -e "${GREEN}[*] Enumerating subdomains using Assetfinder...${RESET}"
assetfinder "$domain" > assetfinder.txt

echo -e "${GREEN}[*] Merging and sorting the results...${RESET}"
cat amass.txt subfinder.txt assetfinder.txt | sort -u > subdomains_unsorted.txt

echo -e "${GREEN}[*] Deleting duplicates and creating a new file...${RESET}"
sort -u subdomains_unsorted.txt > subdomains.txt
rm subdomains_unsorted.txt

echo -e "${GREEN}[+] Subdomain enumeration completed.${RESET}"
echo -e "${GREEN}Results saved in: $PWD/subdomains.txt${RESET}"     


