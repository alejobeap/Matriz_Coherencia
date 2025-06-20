#!/bin/bash

lista=$1

# Check if $list exists
if [[ ! -f $lista ]]; then
  echo "Error: $lista file not found!"
  exit 1
fi

# Loop through each frame ID in the file
while IFS= read -r FRAME_ID; do
  echo "Processing frame: $FRAME_ID"
  ./Compareframe2volcsubsets.sh $FRAME_ID
done < $lista
