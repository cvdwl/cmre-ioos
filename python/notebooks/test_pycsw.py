# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <headingcell level=1>

# CMRE search, access and visualize demo

# <headingcell level=2>

# Search for data using OGC Catalog Service for the Web (CSW)

# <codecell>

from owslib.csw import CatalogueServiceWeb
from owslib import fes
import netCDF4
import numpy as np

# <codecell>

endpoint='http://scsrv26v:8000/pycsw'
#endpoint='http://www.ngdc.noaa.gov/geoportal/csw'
csw = CatalogueServiceWeb(endpoint,timeout=60)
csw.version

# <codecell>

csw.get_operation_by_name('GetRecords').constraints

# <codecell>

def dateRange(start_date='1900-01-01',stop_date='2100-01-01',constraint='overlaps'):
    if constraint == 'overlaps':
        start = fes.PropertyIsLessThanOrEqualTo(propertyname='apiso:TempExtent_begin', literal=stop_date)
        stop = fes.PropertyIsGreaterThanOrEqualTo(propertyname='apiso:TempExtent_end', literal=start_date)
    elif constraint == 'within':
        start = fes.PropertyIsGreaterThanOrEqualTo(propertyname='apiso:TempExtent_begin', literal=start_date)
        stop = fes.PropertyIsLessThanOrEqualTo(propertyname='apiso:TempExtent_end', literal=stop_date)
    return start,stop

# <codecell>

box=[38., 6., 41., 9.]     #  lon_min lat_min lon_max lat_max
start_date='2014-03-12 18:00'
stop_date='2014-09-18 18:00'
val = 'sea_water_potential_temperature'

# <codecell>

# convert User Input into FES filters
start,stop = dateRange(start_date,stop_date)
bbox = fes.BBox(box)
any_text = fes.PropertyIsLike(propertyname='apiso:AnyText',literal=('*%s*' % val),
                        escapeChar='\\',wildCard='*',singleChar='?')

# <codecell>

# combine filters into a list
filter_list = [fes.And([ start, stop, bbox,any_text]) ]

# <codecell>

csw.getrecords2(constraints=filter_list,maxrecords=100,esn='full')
len(csw.records.keys())

# <codecell>

choice=np.random.choice(list(csw.records.keys()))
print(csw.records[choice].title)
csw.records[choice].references

# <codecell>

# get specific ServiceType URL from records
def service_urls(records,service_string='OPeNDAP:OPeNDAP'):
    urls=[]
    for key,rec in records.iteritems():
        #create a generator object, and iterate through it until the match is found
        #if not found, gets the default value (here "none")
        url = next((d['url'] for d in rec.references if d['scheme'] == service_string), None)
        if url is not None:
            urls.append(url)
    return urls

# <codecell>

#scheme='urn:x-esri:specification:ServiceType:odp:url'
scheme='OPeNDAP:OPeNDAP'
urls = service_urls(csw.records,service_string=scheme)
print "\n".join(urls)

# <headingcell level=2>

# Use Iris to access CF data

# <codecell>

import iris
import iris.plot as iplt
import iris.quickplot as qplt
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
%matplotlib inline

# <codecell>

cube = iris.load_cube(urls[7],'sea_water_potential_temperature')

# <codecell>

print cube

# <headingcell level=2>

# Make a nice plot using Cartopy (better than Basemap)

# <codecell>

from matplotlib import rcParams
from matplotlib.ticker import MultipleLocator
rcParams['xtick.direction'] = 'out'
rcParams['ytick.direction'] = 'out'

fig=plt.figure(figsize=(12,8))

# set the projection
ax1 = plt.axes(projection=ccrs.Mercator())

# color filled contour plot
h = iplt.contourf(cube[1,0,:,:],64)

from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
gl=ax1.gridlines(crs=ccrs.PlateCarree(),draw_labels=True)
gl.xlabels_top = False
gl.ylabels_right = False 
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER
# add coastlines, colorbar and title
plt.gca().coastlines(resolution='10m')
plt.colorbar(h,orientation='vertical');
plt.title(cube.attributes['title']);

# <codecell>


