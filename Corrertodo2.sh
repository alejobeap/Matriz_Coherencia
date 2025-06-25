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


  # Al final de cada carpeta, clonar repo y mover contenido
  echo "RUN AVERAGE and MATRIZ"
  (
    cd "$CARPETA" || { echo "No se pudo entrar a $CARPETA"; exit 1; }
    chmod +x *.sh
    #./RSLC2listIFS.sh
    #./Create_filter_IFS.sh
    #mkdir -p log
    #sbatch --qos=high --output=MKIFS_$CARPETA.out --error=MKIFS_$CARPETA.err --job-name=MKIFS_$CARPETA -n 8 --time=23:59:00 --mem=65536 -p comet --account=comet_lics --partition=standard --wrap="LiCSAR_03_mk_ifgs.py -d . -r 7 -a 2 -c 0 -i filtered_date_pairs.txt"
    python Estimate_Coherence_Average_from_list.py $NOMBRE
    python matriz_coherencia.py
    ./filtered_average.sh
    display mnatris.png & display filtered_matriz.png &
  )
done

echo "Proceso finalizado."

