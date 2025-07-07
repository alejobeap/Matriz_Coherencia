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


filename="$RUTA_BASE/corners_clip.149A_11428_131313"
basename="${filename#*.}"

# Check if sourceframe.txt exists and delete it
[ -f sourceframe.txt ] && rm sourceframe.txt

# Write the extracted basename to sourceframe.txt
echo "$basename" > sourceframe.txt


for CARPETA in "${CARPETAS[@]}"; do
  mkdir -p "$CARPETA/geo"
  mkdir -p "$CARPETA/RSLC"
  mkdir -p "$CARPETA/SLC"
  mkdir -p "$CARPETA/GEOC"
  mkdir -p "$CARPETA/GEOC/geo"
  
  
# Check if geo.m or geo exists and copy accordingly
  if [ -d "$RUTA_BASE/$CARPETA/geo.30m" ]; then
    GEO_FOLDER="geo.30m"
  elif [ -d "$RUTA_BASE/$CARPETA/geo" ]; then
    GEO_FOLDER="geo"
  else
    echo "No se encontró carpeta geo.m o geo en $RUTA_BASE/$CARPETA"
    continue
  fi

  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando $GEO_FOLDER en $CARPETA/geo..."
  #scp -r "$RUTA_BASE/$CARPETA/$GEO_FOLDER/"* "$CARPETA/geo/" 2>/dev/null
  rsync -a --ignore-existing "$RUTA_BASE/$CARPETA/$GEO_FOLDER/"* "$CARPETA/geo/" 2>/dev/null

  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando RSLC en $CARPETA..."
  #scp -r "$RUTA_BASE/$CARPETA/RSLC/" "$CARPETA/" 2>/dev/null
  rsync -a --ignore-existing "$RUTA_BASE/$CARPETA/RSLC/" "$CARPETA/RSLC/" 2>/dev/null


  ((PASO_ACTUAL++))
  PORCENTAJE=$(( PASO_ACTUAL * 100 / TOTAL_PASOS ))
  echo "[$PORCENTAJE%] Copiando SLC en $CARPETA..."
#  scp -r "$RUTA_BASE/$CARPETA/SLC/" "$CARPETA/" 2>/dev/null
  rsync -a --ignore-existing "$RUTA_BASE/$CARPETA/SLC/" "$CARPETA/SLC/" 2>/dev/null

  rsync -a --ignore-existing "$RUTA_BASE/$CARPETA/GEOC.meta.30m/" "$CARPETA/GEOC/geo/" 2>/dev/null
  rsync -a --ignore-existing "$RUTA_BASE/$CARPETA/GEOC.meta.30m/*" "$CARPETA/GEOC/" 2>/dev/null



  # Al final de cada carpeta, clonar repo y mover contenido
  echo "Clonando Matriz_Coherencia en $CARPETA..."
  (
    cd "$CARPETA" || { echo "No se pudo entrar a $CARPETA"; exit 1; }
    git clone https://github.com/alejobeap/Matriz_Coherencia.git
    mv Matriz_Coherencia/* ./
    rm -rf Matriz_Coherencia
    chmod +x *.sh
    #sbatch --qos=high --output=Multilook.out --error=Multilook.err --job-name=Multilook_$CARPETA -n 8 --time=23:59:00 --mem=65536 -p comet --account=comet_lics --partition=standard --wrap="./multilookRSLC.sh"

  )
done

echo "Proceso finalizado."
