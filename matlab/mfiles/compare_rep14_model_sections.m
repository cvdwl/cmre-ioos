
% Plot sections distance versus time of glider and model temp and salt
%
% load previously saved data file, or just
% call this script after calling "load_rep14_models.m"
% load_rep14_models
% load cmre_models.mat

[obs.server,obs.name] = fileparts(obs.url);
%obsname = strrep_(obs.name);
obsname = obs.name

switch variable
  case 'temp'
    bins = 22:0.25:30.;
    bins = 13:0.25:26.;
    c = range(bins);
  case 'salt'
 %   bins = 29:0.2:36.5;  %MARACOOS
     bins = 35.5:.1:36.3; % SECOORA
     bins = 37.3:.05:38.5; % CMRE
 %    bins = 37:0.05:38
    c = range(bins);
  otherwise
    c = 'auto';
end

%model_list = {'OBS','ESPreSSo','USEAST','HYCOM'}; %MARACOOS
model_list = {'OBS','SABGOM','USEAST','HYCOM'}; %SECOORA
%model_list = {'OBS','USEAST','HYCOM'}; %SECOORA
model_list = {'OBS','NRLLT','MERCATOR','ROMSREG','SOCIBREG','MFS'}

clf
hax = nfigaxes([length(model_list) 1],[0 0.02],[0.1 0.95],[0.1 0.95]);

for m = 1:length(model_list)
  
  mname = char(model_list{m});
  eval(['model = ' lower(mname)])
  
  axes(hax(m))
  if min(model.(variable).data(:))>=200.
      model.(variable).data=model.(variable).data-273.15;
  end
  pcolorjw(model.(variable).dist,model.(variable).z,model.(variable).data)
  shading interp
  %axis([0 200 -80 0]);
  ax=[0 350 -50 0];
  axis(ax);
  caxis(c)
  colorbar
  
  title_pos=ax(3)+5;
  if m==1
    title(upper(variable))
    text(10,title_pos,{mname,(model.name)},'interpreter','none');
  else
    text(10,title_pos,mname);
  end
  
end

set(hax(1:(end-1)),'xticklabel',[])
xlabel('distance (km)')


