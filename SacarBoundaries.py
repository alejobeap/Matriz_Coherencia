import os

# Archivo de entrada y salida
volcanoes_file = "Volcanes_Chiles.txt"
output_boundaries_file = "volcano_boundaries_20km.txt"

# Constante de conversión de kilómetros a grados (aproximada)
KM_TO_DEGREES = 1.0 / 111.0  # 1 grado ≈ 111 km

def process_volcanoes(volcanoes_file, output_file, distancia_km=20):
    try:
        with open(volcanoes_file, "r") as vf, open(output_file, "w") as out_f:
            next(vf)  # Saltar encabezado

            for line in vf:
                parts = line.strip().split()
                if len(parts) < 3:
                    continue  # Saltar líneas vacías o mal formateadas

                nombre_volcan, lon_str, lat_str = parts[0], parts[1], parts[2]

                lon = float(lon_str)
                lat = float(lat_str)

                cut_deg = distancia_km / 111.0
                half_deg = cut_deg / 2.0

                lonmin = lon - half_deg
                lonmax = lon + half_deg
                latmin = lat - half_deg
                latmax = lat + half_deg

                out_f.write(f"{nombre_volcan} {lon:.6f} {lat:.6f} {lonmin:.6f}/{lonmax:.6f}/{latmin:.6f}/{latmax:.6f}\n")

        print(f"Archivo generado: {output_file}")

    except Exception as e:
        print(f"Error procesando los volcanes: {e}")

if __name__ == "__main__":
    process_volcanoes("Volcanes_Chiles.txt", "volcano_boundaries_20km.txt")
