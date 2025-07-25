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

# Contador de interferogramas
total_count=0
linked_count=0

# Copiar interferogramas válidos según fechas
for dir in "$FRAMEdir"/interferograms/*; do
    [[ -d "$dir" ]] || continue
    total_count=$((total_count + 1))
    
    file_dates=$(basename "$dir")
    file_date1=$(echo "$file_dates" | cut -d '_' -f 1)
    file_date2=$(echo "$file_dates" | cut -d '_' -f 2)

    if [[ $file_date1 -gt $threshold_date && $file_date2 -gt $threshold_date && $file_date2 -lt $threshold_date2 && $file_date1 -lt $threshold_date2 ]]; then
        ln -sf "$dir" .
        linked_count=$((linked_count + 1))
    fi
done

# Mostrar porcentaje de enlaces realizados
if (( total_count > 0 )); then
    percent=$(( 100 * linked_count / total_count ))
    echo "Enlazados $linked_count de $total_count interferogramas ($percent%)"
else
    echo "No se encontraron interferogramas."
fi

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
