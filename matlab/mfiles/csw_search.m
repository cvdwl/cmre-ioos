function s=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme)
% CSW_SEARCH finds data web services for datasets in specified query
% query is limited here to bbox, start,stop, any_text
% enter bbox=[] to omit bounding box
% data web service endpoints of type "scheme" are returned
%
% Usage:
% data_access_urls=csw_search(csw_endpoint,bbox,start,stop,any_text,scheme)
%
% Example:
%csw_endpoint = 'http://www.ngdc.noaa.gov/geoportal/csw';
%bbox = [-75.0 -71.0 39.0 41.0];
%start = '2014-11-12 18:00';
%stop = '2014-11-18 18:00';
%any_text = 'sea_water_salinity';
%scheme = 'urn:x-esri:specification:ServiceType:odp:url'
%data_access_urls = csw_search(csw_endpoint,bbox,start,stop,any_text,scheme)

%paramString=fileread('simple_csw_request.xml');


if ~isempty(bbox),
    load('simple_csw_request_template.mat','paramString');
    paramString = strrep(paramString,'LON_MIN',num2str(bbox(1),'%f'));
    paramString = strrep(paramString,'LON_MAX',num2str(bbox(2),'%f'));
    paramString = strrep(paramString,'LAT_MIN',num2str(bbox(3),'%f'));
    paramString = strrep(paramString,'LAT_MAX',num2str(bbox(4),'%f'));
else
    load('simpler_csw_request_template.mat','paramString');
end
paramString = strrep(paramString,'ANY_TEXT_STRING',any_text);
paramString = strrep(paramString,'TIME_START',start);
paramString = strrep(paramString,'TIME_STOP',stop);

[output,extras] = urlread2(csw_endpoint,'POST',paramString);

% split on records</csw:Record>
[~,~,~,~,records]=regexp(output,'<csw:Record>(.*?)</csw:Record>','match');
s={};
for i=1:length(records)
    record_xml=char(records{i});
    service_template='<dct:references scheme="DATA_SCHEME">(.*?)</dct:references>';
    scheme_expr=strrep(service_template,'DATA_SCHEME',scheme);
    [~,~,~,~,data_url]=regexp(record_xml,scheme_expr,'match');
    if ~isempty(data_url),
        [~,~,~,~,data_title]=regexp(record_xml,'<dc:title>(.*?)</dc:title>','match');
        s{i}.title=char(data_title{1});
        s{i}.scheme=scheme;
        s{i}.url=char(data_url{1});
    end
end


