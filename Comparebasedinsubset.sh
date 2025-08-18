function LS() {
    indir="/gws/nopw/j04/nceo_geohazards_vol1/projects/LiCS/proc/current/subsets/volc/$1"

    for f in "$indir"/*/corners_clip.*; do
        # Extraer el código después de corners_clip.
        code=$(basename "$f" | cut -d'.' -f2)

        # Numérico antes de la letra (quitando ceros a la izquierda)
        num=$(echo "$code" | sed -E 's/^0*([0-9]+)[A-Z].*/\1/')

        # Nombre de carpeta RSLC (ej: 106A, 128D)
        num2=$(basename "$(dirname "$f")")

        # Paths
        path1="$indir/$num2/RSLC"
        path2="/gws/nopw/j04/nceo_geohazards_vol1/public/LiCSAR_products/$num/$code/epochs"

        echo "Comparing:"
        echo "  path1 = $path1"
        echo "  path2 = $path2"

        if [[ -d "$path1" && -d "$path2" ]]; then
            # Guardar diferencias (qué hay en path2 y no en path1)
            missing=$(diff <(ls "$path1") <(ls "$path2") | grep "^>")

            if [[ -z "$missing" ]]; then
                echo "  ✅ Todo está (no falta nada)"
            else
                echo "$missing"
            fi
        else
            echo "  ⚠️  One of the paths does not exist"
        fi
        echo
    done
}
