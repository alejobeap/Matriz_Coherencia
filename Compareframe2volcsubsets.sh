#!/bin/bash

frame=$1
DOSUBSETS=1


# Date and directory paths
today=$(date +%Y%m%d)
curdir=$LiCSAR_procdir
public=$LiCSAR_public

[ ! -d "Lossepoch" ] && mkdir Lossepoch

# Extract the track number from the frame
tr=$(echo $frame | cut -d '_' -f1 | sed 's/^0//' | sed 's/^0//' | rev | cut -c 2- | rev)
frameDir="$curdir/$tr/$frame"
frameDir1="$public/$tr/$frame"

# Debugging output
echo "Frame Directory: $frameDir1"
echo "Subsets Directory: $frameDir/subsets"

# Check if frame directory exists
if [ ! -d "$frameDir1" ]; then
  echo "Frame directory does not exist - are you in the \$BATCH_CACHE_DIR?"
  exit 1
fi

# Process subsets if DOSUBSETS is enabled
if [ "$DOSUBSETS" -eq 1 ]; then
  if [ -d "$frameDir/subsets" ]; then
    echo "Clipping for subsets"

    for subset in $(ls "$frameDir/subsets"); do

#      volcano_name=$(python3 NameVolc2ID.py "$subset" "$frame")
       volcano_name_noclean=$(python3 NameVolc2ID.py "$subset" "$frame" | tr -d "'")
       # Remove spaces and dots
       volcano_name="${volcano_name_noclean//[ .-]/}"


      echo "Processing subset: $subset ($volcano_name)"
      cornersclip="$frameDir/subsets/$subset/corners_clip.$frame"
      subdir="$frameDir/subsets/$subset"
      echo "Subset directory: $subdir"

#      volcano_name=$(python3 NameVolc2ID.py "$subset" "$frame")

      # Check if variable is empty (not found)
      if [ -z "$volcano_name" ]; then
         volcano_name=""
         exit 1
      fi

      # Output file for the subset
      output_file="Lossepoch/${frame}_${subset}_${volcano_name}.txt"
      > "$output_file"  # Clear the file if it already exists

      if [ -f "$cornersclip" ]; then
        # Check for epochs directory
        if [ -d "$frameDir1/epochs" ]; then
          for sdate in $(find "$frameDir1/epochs" -maxdepth 1 -type d -name "20??????" -exec basename {} \;); do
            rslc_path="$frameDir1/epochs/$sdate"
            subdir_rslc="$subdir/RSLC/$sdate"

            #echo "Checking RSLC: $subdir_rslc"
            if [ -d "$rslc_path" ]; then
              if [ ! -d "$subdir_rslc" ]; then
                #echo "Clipping $sdate"
                echo "$sdate" >> "$output_file"
              fi
            else
              echo "Epoch $sdate missing in $rslc_path"
            fi
          done
        else
          echo "Epochs directory does not exist at $frameDir1/epochs"
        fi
      else
        echo "Skipping subset $subset due to missing corners clip file."
      fi
    done
  else
    echo "Subsets directory does not exist in $frameDir"
  fi
fi

echo "Processing completed. Missing dates saved in subset-specific files."
