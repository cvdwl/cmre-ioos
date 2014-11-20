function out_struct=zinterp_struct(modvar_struct,obs_struct);
% ZINTERP_STRUCT  interpolates model structure onto obs z levels
out_struct=modvar_struct;
sz=size(modvar_struct.data);
nprofs=sz(2);

z = modvar_struct.z;
data = modvar_struct.data;


zdiff=z(1,:)-z(end,:);
if min(zdiff(:)) < 0;  % if z(end) is top, then flipud so that z(1)=top
  z = flipdim(z,1);
  data = flipdim(data,1);
end

%%
% Add a layer of z values at 10 m above surface 
z = [10.0+zeros(1,nprofs); z];

% Add a layer of data values above surface cloning the surface values
data = [data(1,:); data];
%%
nzobs=length(obs_struct.z);
di=ones(nzobs,nprofs)*NaN;

for i=1:nprofs,
    if isempty(find(isfinite(z(:,i)+data(:,i)))),
        di(:,i)=NaN*ones(size(obs_struct.z));
    else
        di(:,i)=interp_r(z(:,i),data(:,i),obs_struct.z);
    end
end
%%
out_struct.z=obs_struct.z*ones(1,nprofs);
out_struct.data=di;
out_struct.dist= ones(nzobs,1)*out_struct.dist(1,:);