#!/bin/bash

# Check if the GEOC directory exists
if [ ! -d "GEOC" ]; then
  echo "Error: Directory 'GEOC' does not exist."
  exit 1
fi

# Step 1: Check if listaifs.txt exists and remove it
if [ -f "listaifsunw.txt" ]; then
  echo "Removing existing file: listaifs.txt"
  rm listaifsunw.txt
fi

# Step 2: Create the list of files in GEOC directory
echo "Creating list of files in 'GEOC' directory..."
ls GEOC -1 > listaifsunw.txt

# Step 3: Iterate over the files listed in listaifs.txt
while IFS= read -r file; do
  echo "Processing file: $file"
  if [ -x "./unwrap_geo.sh" ]; then
#    sbatch -A comet -p comet -o sbatch_logs/$file.gapfill.out -e sbatch_logs/$file.gapfill.err -t 72:00:00 ./unwrap_geo.sh 164A_12971_071312 "$file"

     sbatch --qos=high --output=sbatch_logs/$file.out --error=sbatch_logs/$file.err --job-name=$file -n 8 --time=23:59:00 --mem=65536 -p comet --account=comet_lics --partition=standard --wrap="unwrap_geo.sh `cat sourceframe.txt` $file"
  else
    echo "Error: unwrap_geo.sh is not executable or not found."
    exit 1
  fi
done < listaifsunw.txt

echo "Processing completed."
