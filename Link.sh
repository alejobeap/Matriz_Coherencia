#!/bin/bash

FRAME=$(basename "$(pwd)") #"${1}"
TRACK="$(echo $FRAME | cut -c1-3 | bc)"
FRAMEdir="$LiCSAR_public/$TRACK/$FRAME"
threshold_date="20141001"
threshold_date2="20250601"

mkdir -p GEOC
cd GEOC

total_steps=5  # Total number of steps in the process
current_step=0 # Initialize the step counter

update_progress() {
    current_step=$((current_step + 1))
    progress=$((current_step * 100 / total_steps))
    echo "Progress: ${progress}% completed."
}

# Step 1: Copy interferograms
update_progress
for dir in $(ls $FRAMEdir/interferograms/); do
    file_dates="$dir"
    file_date1=$(echo $file_dates | cut -d '_' -f 1)
    file_date2=$(echo $file_dates | cut -d '_' -f 2)
    
    if [[ $file_date1 -gt $threshold_date && $file_date2 -gt $threshold_date && $file_date2 -lt $threshold_date2 && $file_date1 -lt $threshold_date2 ]]; then
        ln -sf "$FRAMEdir/interferograms/$dir" ./
    fi
done

# Step 2: Copy single geo.mli.tif file
update_progress
rm -rf ./*geo.mli.tif
cp $(ls $FRAMEdir/epochs/20*/*.geo.mli.tif | head -1) ./${FRAME}.geo.mli.tif

# Step 3: Copy geo.[ENU].tif metadata files
update_progress
cp -f $FRAMEdir/metadata/*geo.[ENU].tif ./

# Step 4: Copy geo.hgt.tif file
update_progress
cp -f $FRAMEdir/metadata/*geo.hgt.tif ./

# Step 5: Copy baselines file
update_progress
cp -f $FRAMEdir/metadata/baselines ./

cd ..

echo "Processing complete!"
