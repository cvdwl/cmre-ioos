%% TEST 1
bbox=[-75.0 -71.0 39.0 41.0];
start='2014-11-12 18:00';
stop='2014-11-18 18:00';
any_text='salinity';
csw_endpoint = 'http://www.ngdc.noaa.gov/geoportal/csw';
scheme='urn:x-esri:specification:ServiceType:odp:url';
%scheme='OPeNDAP:OPeNDAP';
data_access_urls=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
data_access_urls{1}

%% TEST 2
bbox=[-20. 20. 10. 50.];
start='2014-03-12 18:00';
stop='2014-09-18 18:00';
any_text='temp';
csw_endpoint='http://scsrv26v:8000/pycsw'
scheme='OPeNDAP:OPeNDAP'
data_access_urls=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
data_access_urls{1}
