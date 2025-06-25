#!/bin/bash

# Archivos de entrada y salida
input_file="filtered_IFS_average_cc_value.txt"
months_file="mesecrear.txt"
future_file="futuro.txt"
dates_longs_file="dates_longs.txt"

# Verificar si los archivos existen y borrarlos si es necesario
[ -f "$months_file" ] && rm "$months_file"
[ -f "$future_file" ] && rm "$future_file"
# Nota: dates_longs.txt no se borra

# Extraer fechas únicas
awk '{gsub("_", "\n", $0); print}' "$input_file" | sort -u > "$dates_longs_file"

# Obtener los años únicos
years=($(awk '{print substr($0, 1, 4)}' "$dates_longs_file" | sort -u))

# Mapeo manual de nombres de meses a números
declare -A month_map=(
    [January]=1 [February]=2 [March]=3 [April]=4 [May]=5
    [June]=6 [July]=7 [August]=8 [September]=9 [October]=10
    [November]=11 [December]=12
)

# Generar archivo con los meses y sus ocurrencias por año
declare -A month_years
while read -r date; do
    year=${date:0:4}
    month=${date:4:2}
    month_number=$((10#$month))
    month_name=$(date -d "2023-$month-01" +"%B" 2>/dev/null || echo "")
    
    if [ -n "$month_name" ] && [ -n "${month_map[$month_name]}" ]; then
        month_years[$month_name]+="$year "
    fi
done < "$dates_longs_file"

# Identificar meses que aparecen en al menos 5 años únicos
declare -A valid_months
for key in "${!month_years[@]}"; do
    month_name=$key
    years_present=(${month_years[$key]})
    unique_years=($(printf "%s\n" "${years_present[@]}" | sort -u))

    # Si el mes aparece en al menos 5 años, agregarlo
    if [ ${#unique_years[@]} -ge 3 ]; then
        valid_months[$month_name]=${month_map[$month_name]}
    fi
done

# Crear el archivo de meses (mesecrear.txt)
echo "" > "$months_file"
for month_name in "${!valid_months[@]}"; do
    echo "$month_name ${valid_months[$month_name]}" >> "$months_file"
done

# Crear archivo de meses futuros (futuro.txt)
cp "$months_file" "$future_file"

echo "Archivos creados: $months_file y $future_file"
