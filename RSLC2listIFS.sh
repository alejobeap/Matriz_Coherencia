#!/bin/bash

# Paso 1: Verificar si listarslc.txt existe y eliminarlo si es necesario
if [ -f "listarslc.txt" ]; then
  echo "Eliminando archivo existente: listarslc.txt"
  rm listarslc.txt
fi


# Paso 1: Verificar si listarslc.txt existe y eliminarlo si es necesario
if [ -f "filtered_date_pairs.txt" ]; then
  echo "Eliminando archivo existente: filtered_date_pair.txt"
  rm filtered_date_pairs.txt
fi

# Paso 2: Crear la lista de archivos RSLC
ls RSLC -1 > listarslc.txt

# Paso 3: Extraer fechas válidas de los archivos
dates=()
while read -r rslc_file; do
  date=$(echo "$rslc_file" | grep -oE '[0-9]{8}')
  if [[ $date =~ ^[0-9]{8}$ ]]; then
    dates+=("$date")
  fi
done < listarslc.txt

# Paso 4: Crear pares de fechas según las reglas
output_file="filtered_date_pairs.txt"
> "$output_file"  # Limpiar el archivo de salida si ya existe

for i in "${!dates[@]}"; do
  date1=${dates[$i]}
  year1=${date1:0:4}
  month1=${date1:4:2}

  # Verificar que el primer mes no esté entre mayo y septiembre
  if ((10#$month1 >= 5 && 10#$month1 <= 9)); then
    continue
  fi

  for j in "${!dates[@]}"; do
    date2=${dates[$j]}
    year2=${date2:0:4}
    month2=${date2:4:2}

    # Calcular la diferencia en meses
    year_diff=$((year2 - year1))
    month_diff=$((10#$month2 - 10#$month1 + year_diff * 12))

    # Verificar que la segunda fecha no esté entre mayo y septiembre
    if ((10#$month2 >= 5 && 10#$month2 <= 9)); then
      continue
    fi

    # Asegurarse de que la diferencia sea al menos 3 meses y como máximo 24 meses
    if ((month_diff >= 3 && month_diff <= 13)); then
      echo "${date1}_${date2}" >> "$output_file"
    fi
  done
done

echo "Pares de fechas filtrados guardados en $output_file"
