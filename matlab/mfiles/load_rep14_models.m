
variable = 'salt';
%variable = 'temp';

% will use dynamic field names with structures to process variable named
% above


% -----------------------------------------------------------------------
% Obs: Single glider transect
%obs.url = ['http://tds.marine.rutgers.edu/thredds/dodsC/' ...
%    'cool/glider/mab/Gridded/20101025T000000_20101117T000000_marcoos_ru22.nc']
%obs.url=['http://tds.marine.rutgers.edu/thredds/dodsC/' ...
%    'cool/glider/mab/Gridded/20100402T000000_20100511T000000_cara_ru26d.nc']
%obs.url = ['http://tds.marine.rutgers.edu:8080/thredds/dodsC/' ...
%    'cool/glider/mab/Gridded/20130911T000000_20130920T000000_gp2013_modena.nc']
%obs.url = ['http://tds.marine.rutgers.edu/thredds/dodsC/' ...
%    'cool/glider/mab/Gridded/20130813T000000_20130826T000000_njdep_ru28.nc']
%obs.url=['http://scsrv26v:8080/thredds/dodsC/' ...
%    'models/geos3/REP14/data/NURC/gliders/noa/GL-20140609-noa-MEDREP14depl001-grid-D.nc']
obs.url=['http://scsrv26v:8080/thredds/dodsC/' ...
      'gliders/GL-20140608-zoe-MEDREP14depl001-grid-D.nc.ncml'];
obs.file = obs.url;
obs.temp.name = 'ctd_temp';
obs.salt.name = 'ctd_salt';
obs.lonname  = 'ctd_longitude';
obs.latname  = 'ctd_latitude';
obs.zname    = 'ctd_depth';

nc = ncgeodataset(obs.url)
% Load the observations
disp(['Loading obs from ' obs.url])
disp(['  Variable is ' obs.(variable).name])
data     = double(nc{obs.(variable).name}(:));
%% interp near surface (0-30m) bins, each separately in time
sz=size(data);
x=1:sz(1);
for j=1:30,
    igood=find(~isnan(data(:,j)));
    ti = interp1(x(igood),data(igood,j),x);
    data(:,j)=ti;
end
obs.data = data;

obs.lon  = nc{obs.lonname}(:);
obs.lat  = nc{obs.latname}(:);
obs.z    = -nc{obs.zname}(:);
obs.dist = cumsum([0; sw_dist(obs.lat,obs.lon,'km')]);
obs.(variable).data = data;
obs.(variable).dist = obs.dist;
obs.(variable).z    = obs.z;
%obs.time = nj_time(nc,obs.(variable).name);
obs.time=nc.time('ctd_time');
tstart = min(obs.time);
tend = max(obs.time);
disp('  Time interval of obs:')
disp(['    ' datestr(tstart) ' to ' datestr(tend)])
%

%% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% Model: MERCATOR 
mercator.name = 'mercator';
mercator.url = 'http://scsrv26v:8080/thredds/dodsC/mercator/fmrc/mercator_best.ncd'
mercator.file = mercator.url;
mercator.temp.name = 'temperature'; % in KELVIN!
mercator.salt.name = 'salinity';
% -----------------------------------------------------------------------
% Model: ROMS Free Run
romsfr.name = 'romsfr';
romsfr.url = 'http://scsrv26v:8080/thredds/dodsC/cmre_roms/fmrc/cmre_roms_best.ncd'
romsfr.file = 'romsfr.nc';
romsfr.temp.name = 'temp';
romsfr.salt.name = 'salt';
% -----------------------------------------------------------------------
% Model: MFS
mfs.name = 'mfs';
mfs.url = 'http://scsrv26v:8080/thredds/dodsC/mfs/fmrc/mfs_best.ncd';
mfs.file = 'romsfr.nc';
mfs.temp.name = 'votemper';
mfs.salt.name = 'vosaline';
% -----------------------------------------------------------------------
% Model: NRL_NCOM CF-compliant NCOM aggregation
nrllt.name = 'nrllt';
nrllt.url = 'http://scsrv26v:8080/thredds/dodsC/nrl/fmrc/nrl_best.ncd'
nrllt.file = 'nrl_ncom.nc';
nrllt.temp.name = 'water_temp';
nrllt.salt.name = 'salinity';
% -----------------------------------------------------------------------
% Model: ROMS regular grid
romsreg.name='romsreg';
romsreg.file = 'foo.nc';
romsreg.url='http://scsrv26v:8080/thredds/dodsC/cmre_roms_regular/fmrc/cmre_roms_regular_best.ncd'
romsreg.temp.name = 'temperature';
romsreg.salt.name = 'salinity';
% -----------------------------------------------------------------------
% Model: SOCIB regular grid
socibreg.name='socibreg';
socibreg.file = 'foo.nc';
socibreg.url='http://scsrv26v:8080/thredds/dodsC/socib_roms/fmrc/socib_roms_best.ncd';
socibreg.temp.name = 'temperature';
socibreg.salt.name = 'salinity';


%% models to compare with data

model_list = {'NRLLT','ROMSFR','MERCATOR','MFS'};

ncks = 0;

for m = 1:length(model_list)
    
    tic
    
    mname = char(model_list{m});
    
    % work with a temporary structure named 'model'
    
    eval(['model = ' lower(mname)])
    
    if ncks
        str = nc_genslice(model.url,model.(variable).name,...,
            obs.lon,obs.lat,obs.time,'ncks');
        disp([str ' ' model.name '.nc'])
        return
    end
    
    [Tvar,Tdis,Tzed] = nc_genslice(model.url,model.(variable).name,...
        obs.lon,obs.lat,obs.time,'verbose');
    
    if ~isempty(findstr(model.url,'myocean')) && strcmp(variable,'temp')
        Tvar = Tvar - 272.15;
    end
    model.(variable).data = Tvar;
    model.(variable).dist = Tdis;
    model.(variable).z = Tzed;
    
    % copy 'model' back to the oroginal named strucutre for this model
    eval([model.name ' = model;'])
    tocs(m)=toc;
    disp('----------------------------------------------------------------')
    disp(['  Elapsed time processing ' mname])
    disp(['  was ' num2str(toc,3) ' seconds'])
    disp('----------------------------------------------------------------')
    
end
disp('----------------------------------------------------------------')
disp(['  Total Elapsed Time' ])
disp(['  was ' num2str(sum(tocs),3) ' seconds'])
disp('----------------------------------------------------------------')

clear nc
save cmre_models.mat
