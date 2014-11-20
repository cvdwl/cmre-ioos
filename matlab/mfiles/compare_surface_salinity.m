% COMPARE_SURFACE_SALINITY
% compare surface salinity from various models:
% 1. query metadata database for datasets in specified space/time range
% 2. get data using OPeNDAP endpoints discovered in metadata
% 3. Use NCTOOOLBOX to allow interoperable geospatial subsetting of data
csw_endpoint='http://scsrv26v:8000/pycsw';
bbox=[6. 9. 38. 41.];   % lon_min lon_max lat_min lat_max
start='2014-06-15 18:00';
stop=start;
any_text='sea_water_salinity';
cax=[36.5 38.5];
scheme='OPeNDAP:OPeNDAP';
datasets = csw_search(csw_endpoint,bbox,start,stop,any_text,scheme);
%%
k=0;  % figure number
for i=1:length(datasets)
    % choose only datasets that have 'Model' in the title.
    if strfind(datasets{i}.title,'Model'),
        disp(datasets{i}.title)
        % open as geodataset using NCTOOLBOX
        nc=ncgeodataset(datasets{i}.url);
        % find the variable that has the specified standard_name
        var = find_std_names(nc,any_text);
        ncgvar=nc.geovariable(var);
        % subset using geo coordinates, not indices!
        s.time=datenum(datestr(start)); 
        s.lon=bbox([1 2]);
        s.lat=bbox([3 4]);
        % here the only hack, because in roms native, level[1] is bottom
        % we should add a feature to geosubset to specify 'top' or 'bottom'
        if strfind(datasets{i}.title,'ROMS:Native'),
            s.z_index=32;
        else
            s.z_index=1;
        end
        sub = ncgvar.geosubset(s);

        % just plotting stuff below here
        k=k+1
        figure(k);
        pcolorjw(sub.grid.lon,sub.grid.lat,double(squeeze(sub.data)));
        set(gca,'tickdir','out');
        set(gcf,'color','white');
        set(gca,'xgrid','on','ygrid','on','layer','top'); 
        set(gcf,'color',[0.85 0.85 0.85])
        caxis(cax);
        colorbar;
        title([datasets{i}.title ':' any_text ':' datestr(s.time)],'interpreter','none')
    end
end