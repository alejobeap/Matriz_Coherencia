#!/bin/bash

# Script to create a 'log' directory and run the LiCSAR_03_mk_ifgs.py script with specified arguments

# Create the 'log' directory
mkdir -p log

# Run the LiCSAR_03_mk_ifgs.py script with the given arguments
LiCSAR_03_mk_ifgs.py -d . -r 7 -a 2 -c 0 -i filtered_date_pairs.txt

# Notify the user of completion
echo "Log directory created and LiCSAR_03_mk_ifgs.py executed successfully."
