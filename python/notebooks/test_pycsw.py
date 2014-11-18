# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <headingcell level=1>

# CMRE pyCSW

# <codecell>

from owslib.csw import CatalogueServiceWeb
from owslib import fes
import netCDF4
import numpy as np

# <codecell>

endpoint='http://scsrv26v:8000/pycsw'
endpoint='http://scsrv26v:8000'
endpoint='http://www.ngdc.noaa.gov/geoportal/csw'

csw = CatalogueServiceWeb(endpoint,timeout=60)
csw.version

# <codecell>

csw.get_operation_by_name('GetRecords').constraints

# <codecell>

try:
    csw.get_operation_by_name('GetDomain')
    csw.getdomain('apiso:Format', 'property')
    print(csw.results['values'])
except:
    print('GetDomain not supported')

# <codecell>

try:
    csw.get_operation_by_name('GetDomain')
    csw.getdomain('apiso:ServiceType', 'property')
    print(csw.results['values'])
except:
    print('GetDomain not supported')

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

box=[-20., 10., 20., 50.]  # Italy
start_date='2014-03-12 18:00';
stop_date='2014-09-18 18:00';

# <codecell>

val = 'temperature'
filter1 = fes.PropertyIsLike(propertyname='apiso:AnyText',literal=('*%s*' % val),
                        escapeChar='\\',wildCard='*',singleChar='?')

# <codecell>

# convert User Input into FES filters
start,stop = dateRange(start_date,stop_date)
bbox = fes.BBox(box)

# <codecell>

filter_list = [fes.And([ start, stop, bbox,filter1]) ]

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

scheme='urn:x-esri:specification:ServiceType:odp:url'
#scheme='OPeNDAP:OPeNDAP'
urls = service_urls(csw.records,service_string=scheme)
print "\n".join(urls)

# <codecell>


# <codecell>


