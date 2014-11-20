%SAMPLE ISOSURFACE PLOT
% make sample isosurface plot of temperature and put a glider path on top
figure(1);clf
url='http://scsrv26v:8080/thredds/dodsC/cmre_roms/fmrc/cmre_roms_best.ncd'
nc = ncgeodataset(url);
std_name='sea_water_potential_temperature';
var=find_std_names(nc,std_name);
% grab the 10th time step of temperature
[t,g]=nj_tslice(nc,var,10);
% plot the 15 degree isosurface with a vertical exaggeration of 400
iso_plot(t,g,15.0,400);
title(['Isosurface plot of ' std_name ':' datestr(g.time)],'interpreter','none');

%% add a glider path
url='http://scsrv26v:8080/thredds/dodsC/gliders/GL-20140608-zoe-MEDREP14depl001-grid-D.nc.ncml';
nc=ncgeodataset(url);
var=find_std_names(nc,std_name);
ncvar=nc.geovariable(var);
g=ncvar.grid_interop(:,1);  % get grid at top bin
line(g.lon,g.lat,zeros(size(g.lat)),'color','black');