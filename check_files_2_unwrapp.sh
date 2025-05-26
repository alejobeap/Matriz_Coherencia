#!/bin/bash

# Define base directory
BASE_DIR="GEOC"
# Output file for missing folders
MISSING_LIST="missing_files_list.txt"
# Source frame (example value, modify as needed)
SOURCE_FRAME="149A_11428_131313"

# If missing_files_list.txt exists, delete it
if [[ -f "$MISSING_LIST" ]]; then
    echo "Removing existing $MISSING_LIST"
    rm "$MISSING_LIST"
fi

# Clear or create missing_files_list.txt
> "$MISSING_LIST"

# Loop through subdirectories in the base directory
for SUBDIR in "$BASE_DIR"/*; do
    if [[ -d "$SUBDIR" ]]; then
        # Extract the folder name
        FOLDER_NAME=$(basename "$SUBDIR")
        # Define expected file names
        TIF_FILE="$SUBDIR/${FOLDER_NAME}.geo.unw.tif"
        PNG_FILE="$SUBDIR/${FOLDER_NAME}.geo.unw.png"
        
        # Check if both files exist
        if [[ ! -f "$TIF_FILE" || ! -f "$PNG_FILE" ]]; then
            echo "$FOLDER_NAME" >> "$MISSING_LIST"
        fi
    fi
done

# Check if missing_files_list.txt was created and has content
if [[ -s "$MISSING_LIST" ]]; then
    echo "Processing missing files:"
    
    # Read each line from missing_files_list.txt and run unwrap_geo.sh
    while IFS= read -r LINE; do
        echo "Running unwrap_geo.sh for $SOURCE_FRAME and $LINE"
        unwrap_geo.sh "$SOURCE_FRAME" "$LINE"
    done < "$MISSING_LIST"
else
    echo "No missing files found."
    # Delete empty missing_files_list.txt
    rm "$MISSING_LIST"
fi

echo "Script complete."
