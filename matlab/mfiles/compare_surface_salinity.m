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
    if strfind(datasets{i}.title,'Model'),
        disp(datasets{i}.title)
        nc=ncgeodataset(datasets{i}.url);
        var = find_std_names(nc,any_text);
        ncgvar=nc.geovariable(var);
        s.time=datenum(datestr(start)); 
        s.lon=bbox([1 2]);
        s.lat=bbox([3 4]);
        if strfind(datasets{i}.title,'ROMS:Native'),
            s.z_index=32;
        else
            s.z_index=1;
        end
        sub = ncgvar.geosubset(s);
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