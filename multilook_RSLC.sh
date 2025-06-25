GNU nano 8.2                                                                                      createIG_COH.sh                                                                                                
#!/bin/bash

date1="$1"
date2="$2"
lksrng=13
lksazi=2

set topdir = `pwd`


####

# Get the current directory
topdir=$(pwd)


# Construct the SLC directory path
slc_dir="${topdir}/SLC"

# Check if the SLC directory exists
if [[ -d "$slc_dir" ]]; then
    # Get the name of the folder inside SLC
    folder_name=$(ls -d "$slc_dir"/*/ | head -n 1 | xargs basename)
    echo "Folder inside SLC: $folder_name"
else
    echo "SLC directory does not exist in the current path: $slc_dir"
fi


dateM=$folder_name

#Multilook
#multi_look RSLC/$date1/$date1.rslc RSLC/$date1/$date1.rslc.par RSLC/$date1/$date1.mli RSLC/$date1/$date1.mli.par $lksrng $lksazi
multi_look RSLC/$date1/$date1.rslc RSLC/$date1/$date1.rslc.par RSLC/$date1/$date1.rslc.mli RSLC/$date1/$date1.rslc.mli.par $lksrng $lksazi
#multi_look $date2/$date2.rslc $date2/$date2.rslc.par $date2/$date2.mli $date2/$date2.mli.par $lksrng $lksazi
multi_look RSLC/$date2/$date2.rslc RSLC/$date2/$date2.rslc.par RSLC/$date2/$date2.rslc.mli RSLC/$date2/$date2.rslc.mli.par $lksrng $lksazi

#multi_look $dateM/$dateM.rslc $dateM/$dateM.rslc.par $dateM/$dateM.rslc.mli $dateM/$dateM.rslc.mli.par $lksrng $lksazi

dateM=$folder_name

echo $dateM
