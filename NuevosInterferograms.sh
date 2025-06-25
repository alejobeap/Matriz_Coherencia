#!/bin/bash

# Ensure the script exits on error
set -e

# Create or overwrite IFS.txt with the list of .txt files
output_file="IFS.txt"
if [ -f "$output_file" ]; then
    echo "File $output_file exists. Deleting and recreating it."
    rm "$output_file"
fi
ls RSLC -1 > "$output_file"

# Securely copy the script into the current directory
echo "Copying create_interferograms.sh to the current directory."
scp ../create_interferograms.sh .

# Ensure the script is executable
chmod 777 create_interferograms.sh

# Execute the script with the IFS.txt as input
./create_interferograms.sh "$output_file"

# Prepare variables for job submission
current_dir=$(basename "$(pwd)")
job_output="MK_${current_dir}.out"
job_error="MK_${current_dir}.err"
job_name="MK_${current_dir}"

# Submit the SLURM job
echo "Submitting SLURM job with name $job_name"
sbatch \
    --qos=high \
    --output="$job_output" \
    --error="$job_error" \
    --job-name="$job_name" \
    -n 8 \
    --time=23:59:00 \
    --mem=65536 \
    -p comet \
    --account=comet_lics \
    --partition=standard \
    --wrap="LiCSAR_03_mk_ifgs.py -d . -r 20 -a 4 -f $current_dir -c 0 -T ifgs.log -i combination.txt"
