# Instrucciones para crear la Matriz de Coherencia y crear una lista de interferogramas largos para el caso de los volcanes de Chile

## 1. Identificar el ID con el codigo 
python ../VER_Nombre_volcan.py Socompa
2753

## 2. COPIAR los archivos
mkdir 156D ; scp -r /gws/nopw/j04/nceo_geohazards_vol1/projects/LiCS/proc/current/subsets/volc/2753/156D/RSLC/ 156D/
scp -r /gws/nopw/j04/nceo_geohazards_vol1/projects/LiCS/proc/current/subsets/volc/2753/156D/SLC/ 156D/
mkdir 156D/geo
scp -r /gws/nopw/j04/nceo_geohazards_vol1/projects/LiCS/proc/current/subsets/volc/2753/156D/geo.m/ 156D/geo/

and the all *sh and *py files copy for github
 git clone https://github.com/alejobeap/Matriz_Coherencia.git
 mv Matriz_Coherencia/* .
 rm -rf Matriz_Coherencia/
find . -type f -name "*.sh" -exec chmod +x {} \;

## 3. Crear lista de RSLC y Multilook tod en 7 x 2
   ./multilookRSLC.sh
input listarslc.txt
   Processing date: 20141016
Files for 20141016 are missing. Generating with multilookRSLC...
    Multilooking image 20141016 multilook factor 7 [range] 2 [azimuth] 
Processing date: 20141109
Files for 20141109 are missing. Generating with multilookRSLC...
    Multilooking image 20141109 multilook factor 7 [range] 2 [azimuth]
   
## 4. Crear lista de IFS entre Enero y Mayo y Septiembre-Diciembre sin tomar en cuenta los meses entre Mayo-Septiembre porque es nevado en Chiles
./RSLC2listIFS.sh
input listarslc.txt
output filtered_date_pairs.txt 

### 5. Crear IFS and CC files for list filtered_date_pairs.txt 
./Create_filter_IFS.sh
  or run 
  LiCSAR_03_mk_ifgs.py -d . -r 7 -a 2 -c 0 -i filtered_date_pairs.txt
