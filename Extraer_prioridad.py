#!/usr/bin/env python
"""
MySQL database query wrappers for volcanoes
ML 2023
"""

import pandas as pd
import glob, os
try:
    from LiCSquery import *
    from dbfunctions import Conn_sqlalchemy
    from sqlalchemy import text
except:
    print('error loading LicsInfo tools - volcdb is quite useless then')

from shapely.geometry import Polygon
import geopandas as gpd
import framecare as fc
import fiona
try:
    gpd.io.file.fiona.drvsupport.supported_drivers['KML'] = 'rw'
except:
    pass

fiona.drvsupport.supported_drivers['KML'] = 'rw'

try:
    subvolcpath = os.path.join(os.environ['LiCSAR_procdir'], 'subsets', 'volc')
except:
    print('no LiCSAR_procdir ? subvolcpath is set wrong (but leaving for now)')
    subvolcpath = 'subsets/volc'


def get_volc_info_a2():
    """
    Muestra todos los volcanes con prioridad 'A2',
    con el volc_id como índice y el nombre como primera columna.
    """
    sql = """
        SELECT volc_id, name, lat, lon, alt, priority, 
               vportal_area, vportal_name, ST_AsBinary(geometry) AS geom
        FROM volcanoes
        WHERE priority = 'A2';
    """
    engine = Conn_sqlalchemy()
    with engine.connect() as conn:
        df = gpd.GeoDataFrame.from_postgis(text(sql), conn, geom_col='geom')

    # Usar volc_id como índice
    df.set_index('volc_id', inplace=True)

    # Poner 'name' como primera columna
    cols = ['name'] + [c for c in df.columns if c != 'name']
    df = df[cols]

    # Ordenar por volc_id
    df.sort_index(inplace=True)

    return df


if __name__ == "__main__":
    volcanoes_a2 = get_volc_info_a2()
    print(volcanoes_a2)
