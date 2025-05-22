import os
import rasterio
import numpy as np
import matplotlib.pyplot as plt
from rasterio.windows import from_bounds
from pathlib import Path

# Coordenadas del centro
lon_center = -68.246
lat_center = -24.396

# Dimensiones de corte en kilÃ³metros
cut_size_km = 20.0

# Convertir kilÃ³metros a grados aproximadamente (1 grado = 111 km)
cut_size_deg = cut_size_km / 111.0

# Calcular lÃ­mites de la ventana de corte
min_lon = lon_center - cut_size_deg / 2
max_lon = lon_center + cut_size_deg / 2
min_lat = lat_center - cut_size_deg / 2
max_lat = lat_center + cut_size_deg / 2

# Leer lista de archivos date1_date2
input_txt = "filtered_date_pairs.txt"
output_txt = "output_averages_from_cc_tifs.txt"

output_txt_std = "output_std_from_cc_tifs.txt"


def crop_and_calculate_average(file_path, min_lon, max_lon, min_lat, max_lat, save_image=False):
    try:
        with rasterio.open(file_path) as src:
            print(f"Procesando archivo: {file_path}")
            print(f"ExtensiÃ³n geogrÃ¡fica: {src.bounds}")

            # Calcular ventana en coordenadas del archivo
            window = from_bounds(min_lon, min_lat, max_lon, max_lat, src.transform)

            # Leer la ventana de datos
            data = src.read(1, window=window)

            # Mostrar valores bÃ¡sicos
            print(f"Datos cargados: min={np.nanmin(data)}, max={np.nanmax(data)}, nodata={src.nodata}")

            # Guardar imagen recortada si se solicita
            if save_image:
                plt.imshow(data/np.nanmax(data), cmap='viridis')
                plt.colorbar(label='Valores')
                plt.title(f"Recorte de {file_path.stem}")
                plt.savefig(f"recorte_{file_path.stem}.png")
                print(f"Imagen recortada guardada como recorte_{file_path.stem}.png")

            # Calcular promedio ignorando NaNs
            average = np.nanmean(data[data != src.nodata]/np.nanmax(data))
            standar = np.nanstd(data[data != src.nodata]/np.nanmax(data))

            print("AVERAGE",average,standar)

            return average, standar
    except Exception as e:
        print(f"Error procesando {file_path}: {e}")
        return None, None



def main():
    with open(input_txt, "r") as f:
        date_paths = f.read().splitlines()

    results = []
    resultsstd = []
    total_files = len(date_paths)

    for i, date_path in enumerate(date_paths):
        file_path = Path(f"GEOC/{date_path}/{date_path}.geo.cc.tif")

        print(f"Intentando procesar archivo: {file_path}")

        if not file_path.exists():
            print(f"Archivo no encontrado: {file_path}")
            continue

        save_image = (i == 0)  # Guardar solo la primera imagen recortada
        average, standar = crop_and_calculate_average(file_path, min_lon, max_lon, min_lat, max_lat, save_image=save_image)
        print("Average",average)
        if average is not None:
            results.append({"date": date_path, "average": average})

        # Imprimir porcentaje del progreso
        progress = ((i + 1) / total_files) * 100
        print(f"Progreso: {progress:.2f}% completado")

    # Guardar resultados en un archivo de texto
    with open(output_txt, "w") as f:
        for result in results:
            f.write(f"{result['date']} {result['average']:.4f}\n")



        if standar is not None:
            resultsstd.append({"date": date_path, "standar": standar})

    # Guardar resultados en un archivo de texto
    with open(output_txt_std, "w") as f:
        for resultstd in resultsstd:
            f.write(f"{resultstd['date']} {resultstd['standar']:.4f}\n")


if __name__ == "__main__":
    main()
