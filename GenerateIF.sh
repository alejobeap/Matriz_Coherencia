#!/bin/bash

# Script to generate interferograms using SAR data
# Usage: ./script.sh <date1> <date2>

# Input validation
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <date1> <date2>"
    exit 1
fi

# Exit on error
set -e

# Input dates
date1="$1"
date2="$2"

# Look parameters
lksrng=7
lksazi=2

# Get the current directory
topdir=$(pwd)

# Directories
slc_dir="${topdir}/SLC"
geo_dir="${topdir}/geo"
ifg_dir="${topdir}/IFG"
geoc_dir="${topdir}/GEOC"

# Check if SLC directory exists
if [[ ! -d "$slc_dir" ]]; then
    echo "Error: SLC directory does not exist in the current path: $slc_dir"
    exit 1
fi

# Get the name of the first folder inside SLC
folder_name=$(ls -d "$slc_dir"/*/ | head -n 1 | xargs basename)
if [[ -z "$folder_name" ]]; then
    echo "Error: No folders found inside $slc_dir"
    exit 1
fi

dateM=$folder_name
echo "Master date identified as: $dateM"

# Create output directories if not exist
mkdir -p "$ifg_dir" "$geoc_dir"

# Function to perform multilooking
perform_multilook() {
    local date="$1"
    echo "Performing multilook for $date..."
    multi_look "RSLC/$date/$date.rslc" \
               "RSLC/$date/$date.rslc.par" \
               "RSLC/$date/$date.rslc.mli" \
               "RSLC/$date/$date.rslc.mli.par" \
               $lksrng $lksazi
}

# Multilooking for the specified dates
perform_multilook "$date1"
perform_multilook "$date2"

# Interferogram parameters
master=$dateM
m_slc=$date1
s_slc=$date2
ifgpar="${m_slc}_${s_slc}"

# Create IFG directory for this pair
mkdir -p "${ifg_dir}/${ifgpar}"
echo "Computing Interferogram for pair: $ifgpar"

# Extract master file information
if [[ -e "${slc_dir}/${master}/${master}.slc.mli.par" ]]; then
    width=$(awk '$1 == "range_samples:" {print $2}' "${slc_dir}/${master}/${master}.slc.mli.par")
    length=$(awk '$1 == "azimuth_lines:" {print $2}' "${slc_dir}/${master}/${master}.slc.mli.par")
    reducfac=$(awk -v width="$width" 'BEGIN {print (width / 1000 > 1) ? int(width / 1000) : 1}')
else
    echo "Error: Master SLC parameter file not found."
    exit 1
fi

# Interferogram computation
create_offset "RSLC/$date1/$date1.rslc.par" \
              "RSLC/$date2/$date2.rslc.par" \
              "${ifgpar}.off" 1 $lksrng $lksazi 0

phase_sim_orb "RSLC/$date1/$date1.rslc.par" \
              "RSLC/$date2/$date2.rslc.par" \
              "${ifgpar}.off" \
              "${geo_dir}/${master}.hgt" \
              "${ifgpar}.sim_unw" \
              "RSLC/$date1/$date1.rslc.par" - - 1 1

SLC_diff_intf "RSLC/$date1/$date1.rslc" \
              "RSLC/$date2/$date2.rslc" \
              "RSLC/$date1/$date1.rslc.par" \
              "RSLC/$date2/$date2.rslc.par" \
              "${ifgpar}.off" "${ifgpar}.sim_unw" \
              "${ifg_dir}/${ifgpar}/${ifgpar}.diff" \
              $lksrng $lksazi 0 0 0.2 1 1

# Compute coherence
cc_wave "${ifg_dir}/${ifgpar}/${ifgpar}.diff" \
        "RSLC/$date1/$date1.rslc.mli" \
        "RSLC/$date2/$date2.rslc.mli" \
        "${ifg_dir}/${ifgpar}/${ifgpar}.cc" \
        $width 5 5 1

# Geocoding parameters
length_dem=$(awk '$1 == "nlines:" {print $2}' "${geo_dir}/EQA.dem_par")
width_dem=$(awk '$1 == "width:" {print $2}' "${geo_dir}/EQA.dem_par")

# Geocode differential interferogram
geocode_back "${ifg_dir}/${ifgpar}/${ifgpar}.diff" \
             $width \
             "${geo_dir}/${master}.lt_fine" \
             "${geoc_dir}/${ifgpar}/${ifgpar}.geo.diff" \
             $width_dem $length_dem 0 1

data2geotiff "${geo_dir}/EQA.dem_par" \
             "${geoc_dir}/${ifgpar}/${ifgpar}.geo.diff" \
             2 "${geoc_dir}/${ifgpar}/${ifgpar}.geo.diff.tif" 0.0

echo "Geocoding complete for pair: $ifgpar"
