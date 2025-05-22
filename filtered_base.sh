#!/bin/bash

input_file="average_bperp.txt"
output_file="filtered_IFS_baselinevalue.txt"

# Clear output file if it exists
> "$output_file"

while IFS= read -r line
do
  # Extract second column value
  col2=$(echo "$line" | awk '{print $2}')
  
  # Check if col2 is empty
  if [[ -z "$col2" ]]; then
    continue
  fi

  # Check if col2 is a valid number
  if ! [[ "$col2" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    continue
  fi

  # Check threshold condition
  # Only keep if col2 > 100 or col2 < -100
  awk -v val="$col2" 'BEGIN{if(val > 100 || val < -100) exit 0; else exit 1}'
  if [[ $? -eq 0 ]]; then
    # Extract first column and append to output file
    echo "$line" | awk '{print $1}' >> "$output_file"
  fi

done < "$input_file"
