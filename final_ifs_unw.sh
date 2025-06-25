#!/bin/bash

# Script to create a 'log' directory and run the LiCSAR_03_mk_ifgs.py script with specified arguments
tracks=$(basename "$(pwd)")
name=$(basename "$(dirname "$(pwd)")")

# Create the 'log' directory
mkdir -p log

if [[ ! -d "GEOC_longs" ]]; then
    if [[ -d "GEOC" ]]; then
        mv GEOC GEOC_longs
        echo "Carpeta GEOC movida a GEOC_longs porque GEOC_longs no existía."
    else
        echo "No existe GEOC ni GEOC_longs. Continuando sin mover."
    fi
else
    echo "GEOC_longs ya existe. Continuando sin mover."
fi

#mv GEOC GEOC_longs


# Archivos y carpetas
input_list="IFSforLiCSBAS.txt"
faltantes_list="IFSforLiCSBAS_faltantes.txt"
geoc_dir="GEOC"
longs_dir="GEOC_longs"
shorts_dir="GEOC_shorts"

# Crear carpeta GEOC si no existe
mkdir -p "$geoc_dir"

# Limpiar lista de faltantes si ya existe
> "$faltantes_list"

while IFS= read -r folder; do
    long_path="$longs_dir/$folder"
    short_path="$shorts_dir/$folder"
    link_path="$geoc_dir/$folder"

    if [[ -d "$long_path" ]]; then
        # Crear enlace simbólico relativo desde GEOC a GEOC_longs/folder
        ln -s "../$long_path" "$link_path"
        echo "Vínculo creado para $folder desde $longs_dir."
    elif [[ -d "$short_path" ]]; then
        ln -s "../$short_path" "$link_path"
        echo "Vínculo creado para $folder desde $shorts_dir."
    else
        echo "$folder" >> "$faltantes_list"
        echo "$folder no encontrado en $longs_dir ni en $shorts_dir."
    fi
done < "$input_list"

# Resultado final
if [[ -s $faltantes_list ]]; then
    echo "La lista de carpetas faltantes se ha guardado en $faltantes_list."
else
    echo "No faltan carpetas. Todas las carpetas de $input_list están en $longs_dir o $shorts_dir."
    rm "$faltantes_list"  # Eliminar archivo si está vacío
fi



## Crear jobs
sbatch --qos=high --output=LONGS_MKIFS_${name}_${tracks}.out --error=LONGS_MKIFS_${name}_${tracks}.err --job-name=LONGS_MKIFS_${name}_${tracks} -n 8 --time=23:59:00 --mem=65536 -p comet --account=comet_lics --partition=standard --wrap="LiCSAR_03_mk_ifgs.py -d . -r 7 -a 2 -c 0 -i IFSforLiCSBAS_faltantes.txt"

# Run the LiCSAR_03_mk_ifgs.py script with the given arguments
#LiCSAR_03_mk_ifgs.py -d . -r 7 -a 2 -c 0 -i IFSforLiCSBAS.txt"

# Notify the user of completion
echo "Log directory created and LiCSAR_03_mk_ifgs.py executed successfully."



