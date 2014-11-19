%% TEST 1 (NGDC Geoportal)
bbox=[-75.0 -71.0 39.0 41.0];
start='2014-11-12 18:00';
stop='2014-11-18 18:00';
any_text='sea_water_salinity';
csw_endpoint = 'http://www.ngdc.noaa.gov/geoportal/csw';
scheme='urn:x-esri:specification:ServiceType:odp:url';
%scheme='OPeNDAP:OPeNDAP';
s=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
length(s)
s{1}


%% TEST 2 (CMRE no bounding box)
bbox=[];
start='2014-03-12 18:00';
stop='2014-09-18 18:00';
any_text='sea_water_potential_temperature';
csw_endpoint='http://scsrv26v:8000/pycsw';
scheme='OPeNDAP:OPeNDAP';
s=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
length(s)
s{1}

%% TEST 3 (CMRE with bounding box)
csw_endpoint='http://scsrv26v:8000/pycsw';
bbox=[6. 9. 38. 41.];   % lon_min lon_max lat_min lat_max
start='2014-03-12 18:00';
stop='2014-09-18 18:00';
any_text='sea_water_potential_temperature';
%scheme='OGC:WMS'
scheme='OPeNDAP:OPeNDAP';
s = csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
length(s)
s{1}

