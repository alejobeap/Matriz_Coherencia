import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Cargar los datos del archivo
file_path = "output_averages_from_cc_tifs.txt"
data = []

with open(file_path, "r") as file:
    for line in file:
        parts = line.strip().split()
        if len(parts) == 2:
            dates, value = parts
            date1, date2 = dates.split("_")
            data.append([date1, date2, float(value)])

# Crear un DataFrame
df = pd.DataFrame(data, columns=["date1", "date2", "coherence"])

# Crear una matriz de coherencia
unique_dates1 = sorted(df["date1"].unique())
unique_dates2 = sorted(df["date2"].unique())
matrix = np.full((len(unique_dates1), len(unique_dates2)), np.nan)

matrix_filt = np.full((len(unique_dates1), len(unique_dates2)), np.nan)


# Rellenar la matriz con los valores de coherencia
for _, row in df.iterrows():
    i = unique_dates1.index(row["date1"])
    j = unique_dates2.index(row["date2"])
    matrix[i, j] = row["coherence"]

# Graficar la matriz
plt.figure(figsize=(25, 15))
cmap = plt.cm.viridis
plt.imshow(matrix, cmap=cmap, aspect="auto", origin="upper")

# AÃ±adir etiquetas a los ejes
plt.xticks(ticks=range(len(unique_dates2)), labels=unique_dates2, rotation=90, fontsize=8)
plt.yticks(ticks=range(len(unique_dates1)), labels=unique_dates1, fontsize=8)
plt.colorbar(label="Coherence")
plt.title("Matrix of Coherence")
plt.xlabel("Date2")
plt.ylabel("Date1")

# Guardar la imagen
plt.tight_layout()
output_file = "mnatris.png"
plt.savefig(output_file, dpi=100)
plt.close()

print(f"Imagen guardada como {output_file}")





# Rellenar la matriz con los valores de coherencia
for _, row in df.iterrows():
    if row["coherence"]>0.25:
      i = unique_dates1.index(row["date1"])
      j = unique_dates2.index(row["date2"])
      matrix_filt[i, j] = row["coherence"]
    else:
      continue


# Graficar la matriz
plt.figure(figsize=(30, 15))
cmap = plt.cm.viridis
plt.imshow(matrix_filt, cmap=cmap, aspect="auto", origin="upper")

# AÃ±adir etiquetas a los ejes
plt.xticks(ticks=range(len(unique_dates2)), labels=unique_dates2, rotation=90, fontsize=8)
plt.yticks(ticks=range(len(unique_dates1)), labels=unique_dates1, fontsize=8)
plt.colorbar(label="Coherence")
plt.title("Matrix Filtrada of Coherence")
plt.xlabel("Date2")
plt.ylabel("Date1")

# Guardar la imagen
plt.tight_layout()
output_file = "filtered_matriz.png"
plt.savefig(output_file, dpi=100)
plt.close()

print(f"Imagen guardada como {output_file}")
