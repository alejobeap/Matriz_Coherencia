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

# Obtener interferogramas válidos primero
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

# Hacer enlace simbólico y mostrar progreso
for dir in "${valid_dirs[@]}"; do
    ln -sf "$dir" ./
    count=$((count + 1))
    percent=$(( 100 * count / total ))
    echo -ne "Enlazando: $count de $total [$percent%]\r"
done
echo -e "\nListo: Se enlazaron $count interferogramas."

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
