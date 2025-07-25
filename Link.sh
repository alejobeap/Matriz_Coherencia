#!/bin/bash

# Variables base
FRAME=$(basename "$(pwd)")
TRACK=$(echo "$FRAME" | cut -c1-3 | bc)
FRAMEdir="$LiCSAR_public/$TRACK/$FRAME"

# Fechas
threshold_date="20141001"
threshold_date2=$(date +%Y%m%d)  # Fecha actual automática

# Crear y moverse a carpeta GEOC
mkdir -p GEOC
cd GEOC || exit 1

# Obtener interferogramas válidos
valid_dirs=()
for dir in "$FRAMEdir"/interferograms/*; do
    [[ -d "$dir" ]] || continue

    file_dates=$(basename "$dir")
    file_date1=$(echo "$file_dates" | cut -d '_' -f 1)
    file_date2=$(echo "$file_dates" | cut -d '_' -f 2)

    if [[ $file_date1 -gt $threshold_date && $file_date2 -gt $threshold_date && $file_date2 -lt $threshold_date2 && $file_date1 -lt $threshold_date2 ]]; then
        valid_dirs+=("$dir")
    fi
done

# Total de válidos
total=${#valid_dirs[@]}
count=0

# Enlazar solo si es necesario
for full_path in "${valid_dirs[@]}"; do
    dir_name=$(basename "$full_path")
    link_target="$PWD/$dir_name"

    if [[ -L "$link_target" ]]; then
        current_target=$(readlink "$link_target")
        if [[ "$current_target" == "$full_path" ]]; then
            # Enlace ya existe correctamente
            :
        else
            # Apunta a otro lugar, actualizar
            ln -sf "$full_path" "$link_target"
        fi
    elif [[ -e "$link_target" ]]; then
        echo "Aviso: '$dir_name' existe pero no es un enlace. No se toca."
        continue
    else
        ln -s "$full_path" "$link_target"
    fi

    count=$((count + 1))
    percent=$((100 * count / total))
    echo -ne "Enlazando: $count de $total [$percent%]\r"
done

echo -e "\nListo: Se enlazaron/verificaron $count interferogramas."

# Eliminar geo.mli.tif anterior y copiar uno nuevo
rm -f ./*geo.mli.tif
first_geo=$(find "$FRAMEdir"/epochs/20*/ -name '*.geo.mli.tif' | head -1)
if [[ -n "$first_geo" ]]; then
    cp "$first_geo" "${FRAME}.geo.mli.tif"
else
    echo "Advertencia: No se encontró archivo geo.mli.tif"
fi

# Copiar metadatos adicionales
cp -f "$FRAMEdir"/metadata/*geo.[ENU].tif . 2>/dev/null
cp -f "$FRAMEdir"/metadata/*geo.hgt.tif . 2>/dev/null
cp -f "$FRAMEdir"/metadata/baselines . 2>/dev/null

cd ..
