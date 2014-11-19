csw_endpoint='http://scsrv26v:8000/pycsw';
bbox=[6. 9. 38. 41.];   % lon_min lon_max lat_min lat_max
start='2014-03-12 18:00';
stop='2014-09-18 18:00';
any_text='sea_water_salinity';
scheme='OPeNDAP:OPeNDAP';
s = csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
for i=1:length(s)
    s{i}
end