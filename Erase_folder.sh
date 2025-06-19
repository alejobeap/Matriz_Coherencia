#!/bin/bash

# Define the parent directory
GEOC_DIR="GEOC"

# Iterate through subdirectories in GEOC
for dir in "$GEOC_DIR"/*; do
    if [ -d "$dir" ]; then
        # Check if the directory is empty
        if [ -z "$(ls -A "$dir")" ]; then
            echo "Deleting empty folder: $dir"
            rm -rf "$dir"
            continue
        fi

        # Check for specific file patterns
        contains_landmask_tif=$(find "$dir" -type f -name "*.geo.landmask.tif" | wc -l)
        contains_hillshade_nc=$(find "$dir" -type f -name "hillshade.nc" | wc -l)

        # Delete if it contains only hillshade.nc or specific files
        if [ $contains_hillshade_nc -gt 0 ] && [ $contains_landmask_tif -eq 0 ]; then
            echo "Deleting folder (contains only hillshade.nc): $dir"
            rm -rf "$dir"
            continue
        fi

        if [ $contains_landmask_tif -gt 0 ]; then
            echo "Deleting folder (contains landmask.tif files): $dir"
            rm -rf "$dir"
            continue
        fi
    fi
done
