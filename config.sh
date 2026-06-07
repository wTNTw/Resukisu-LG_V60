#!/bin/bash

# Usage: ./config_trace.sh <config_file> [search_path]
# Example: ./config_trace.sh arch/arm64/configs/vendor/timelm.config net/

CONFIG_FILE=$1
SEARCH_PATH=${2:-.} 

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' not found."
    exit 1
fi

echo "Mapping configs from $CONFIG_FILE in scope: $SEARCH_PATH"
echo "--------------------------------------------------------"
printf "%-35s | %-50s\n" "CONFIG_SYMBOL" "KCONFIG PATH"
echo "--------------------------------------------------------"

# Find all Kconfig files in the specified path once
# This is faster than finding them for every single config loop
KCONFIG_FILES=$(find "$SEARCH_PATH" -type f -name "Kconfig*")

# Loop through the config file
grep -E '^CONFIG_[A-Z0-9_]+=[ym]' "$CONFIG_FILE" | cut -d'=' -f1 | while read -r line; do
    SYMBOL=${line#CONFIG_}

    # Search for the definition 'config SYMBOL' in the indexed Kconfig files
    # Using -F for fixed string search and -l to just print the filename
    PATH_FOUND=$(grep -l -r -E "^\s*config\s+$SYMBOL\b" $KCONFIG_FILES 2>/dev/null | head -n 1)

    if [ -n "$PATH_FOUND" ]; then
        printf "%-35s | %-50s\n" "$line" "$PATH_FOUND"
    else
        printf "%-35s | %-50s\n" "$line" "[!] NOT FOUND IN $SEARCH_PATH"
    fi
done
