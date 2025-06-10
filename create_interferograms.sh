#!/bin/bash

# File containing the list of dates (one date per line in YYYYMMDD format)
INPUT_FILE="listarslc.txt"
OUTPUT_FILE="output_averages_from_cc_tifs.txt"

# Ensure the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file $INPUT_FILE not found!"
    exit 1
fi

# Read dates into an array
dates=($(cat "$INPUT_FILE"))

# Function to calculate month difference
month_diff() {
    local start_date="$1"
    local end_date="$2"
    local start_year=${start_date:0:4}
    local start_month=$((10#${start_date:4:2})) # Strip leading zero
    local end_year=${end_date:0:4}
    local end_month=$((10#${end_date:4:2}))   # Strip leading zero
    echo $(((end_year - start_year) * 12 + (end_month - start_month)))
}

# Function to check if a date falls in the excluded months (May to September)
is_excluded_month() {
    local date="$1"
    local month=$((10#${date:4:2})) # Strip leading zero
    if ((month >= 5 && month <= 9)); then
        return 0 # Excluded
    else
        return 1 # Not excluded
    fi
}

# Generate combinations for intervals, excluding dates in May to September
generate_combinations() {
    local interval=$1
    echo "Generating combinations for interval of $interval months..."
    for ((i = 0; i < ${#dates[@]}; i++)); do
        if is_excluded_month "${dates[i]}"; then
            continue # Skip if the start date is in the excluded range
        fi
        for ((j = i + 1; j < ${#dates[@]}; j++)); do
            if is_excluded_month "${dates[j]}"; then
                continue # Skip if the end date is in the excluded range
            fi
            diff=$(month_diff "${dates[i]}" "${dates[j]}")
            if ((diff >= interval)); then
                echo "${dates[i]}_${dates[j]}" >> "$OUTPUT_FILE"
            fi
        done
    done
}

# Clear the output file
> "$OUTPUT_FILE"

# Generate combinations for 2, 3, and 6 months
generate_combinations 2
generate_combinations 3
generate_combinations 6

echo "Combinations written to $OUTPUT_FILE"
