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
    #print('error, export to kml not working (update geopandas)')

fiona.drvsupport.supported_drivers['KML'] = 'rw'

try:
    subvolcpath = os.path.join(os.environ['LiCSAR_procdir'], 'subsets', 'volc') #/volc/267)
except:
    print('no LiCSAR_procdir ? subvolcpath is set wrong (but leaving for now)')
    subvolcpath = 'subsets/volc'

def export_all_volclips_to_kml(outkml):
    """e.g. outkml='/gws/nopw/j04/nceo_geohazards_vol1/public/shared/temp/earmla/volclips.kml'"""
    volclips=get_volclips_gpd()
    volclips.to_file(outkml, driver='KML')



def get_volclips_gpd(vid=None):
    """Gets volclips as geodatabase - either one if given vid, or all"""
    if vid:
        cond = " where vc.vid={}".format(str(vid))
    else:
        cond = ''
    #sql = "SELECT ST_AsBinary(geometry) as geom from volclips {0};".format(cond)
    sql = "SELECT v.volc_id,v.name,vc.vid,ST_AsBinary(vc.geometry) as geom from volclips vc inner join volclip2volcs vf on vf.vid=vc.vid inner join volcanoes v on vf.volc_id=v.volc_id {0};".format(cond)
    engine=Conn_sqlalchemy()
    with engine.connect() as conn:
        volclips = gpd.GeoDataFrame.from_postgis(text(sql), conn, geom_col='geom')
    #volclips = gpd.GeoDataFrame.from_postgis(sql, engine, geom_col='geom' )
    return volclips


import os

outkml = os.path.join(os.getcwd(), "volclips.kml")
export_all_volclips_to_kml(outkml)
