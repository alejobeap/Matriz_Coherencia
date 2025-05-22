#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: $0 <nombre_carpeta>"
  exit 1
fi

NOMBRE=$1

NUMERO=$(python3 VER_Nombre_volcan.py "$NOMBRE" | tr -d '[]')
if [ $? -ne 0 ] || [ -z "$NUMERO" ]; then
  echo "Error ejecutando VER_Nombre_volcan.py o valor vacío"
  exit 1
fi

echo "Número obtenido: $NUMERO"

mkdir -p "$NOMBRE"
cd "$NOMBRE" || { echo "No se pudo entrar a la carpeta $NOMBRE"; exit 1; }

RUTA_BASE="/gws/nopw/j04/nceo_geohazards_vol1/projects/LiCS/proc/current/subsets/volc/$NUMERO"

CARPETAS=( $(ls -d "$RUTA_BASE"/*/ 2>/dev/null | xargs -n 1 basename) )

if [ ${#CARPETAS[@]} -eq 0 ]; then
  echo "No se encontraron carpetas dentro de $RUTA_BASE"
  exit 1
fi

TOTAL_PASOS=$((${#CARPETAS[@]} * 3))
PASO_ACTUAL=0

for CARPETA in "${CARPETAS[@]}"; do
  mkdir -p "$CARPETA/geo"
  
  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando geo.m en $CARPETA/geo..."
  scp -r "$RUTA_BASE/$CARPETA/geo.m/" "$CARPETA/geo/" 2>/dev/null

  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando RSLC en $CARPETA..."
  scp -r "$RUTA_BASE/$CARPETA/RSLC/" "$CARPETA/" 2>/dev/null

  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando SLC en $CARPETA..."
  scp -r "$RUTA_BASE/$CARPETA/SLC/" "$CARPETA/" 2>/dev/null

  # Al final de cada carpeta, clonar repo y mover contenido
  echo "Clonando Matriz_Coherencia en $CARPETA..."
  (
    cd "$CARPETA" || { echo "No se pudo entrar a $CARPETA"; exit 1; }
    git clone https://github.com/alejobeap/Matriz_Coherencia.git
    mv Matriz_Coherencia/* ./
    rm -rf Matriz_Coherencia
  )
done

echo "Proceso finalizado."
