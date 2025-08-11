#!/bin/bash
star="2025-06-01"
final=$(date +%Y-%m-%d)

while IFS= read -r linea || [[ -n "$linea" ]]; do
    echo "=== Processing: $linea ==="
    ./framebatch_data_refill.sh -f "$linea" "$star" "$final"
    echo "Run for $linea between $star and $final"
    licsar_make_frame.sh -P -f "$linea" 1 1 "$star" "$final"
done < listaupdateChile.txt

