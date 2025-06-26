#!/bin/bash

# Directory containing the job scripts
JOB_DIR="gapfill_job"
LOG_DIR="sbatch_logs"

# Ensure the log directory exists
mkdir -p $LOG_DIR

# Iterate over job files in the specified directory
for file_path in $JOB_DIR/unwjob_*.sh; do
    # Extract the job file name without the path
    file=$(basename "$file_path" .sh)

    # Submit the job using sbatch
    sbatch --qos=high \
           --output=$LOG_DIR/$file.out \
           --error=$LOG_DIR/$file.err \
           --job-name="${file}_unw" \
           -n 8 \
           --time=23:59:00 \
           --mem=65536 \
           --partition=standard \
           --account=comet_lics \
           --wrap="bash $file_path"
done

