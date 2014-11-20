load cmre_models
sz=size(romsfr.salt.data);
nprofs=sz(2);

z = romsfr.salt.z;
data = romsfr.salt.data;

zdiff=z(1,:)-z(end,:);
if min(zdiff(:)) < 0;  % if z(end) is top, then flipud so that z(1)=top
  z = flipdim(z,1);
  data = flipdim(data,1);
end

%%
% Add a layer of z values 10 m above surface 
z = [10+zeros(1,nprofs); z];

% Add a layer of data values above surface cloning the surface values
data = [data(1,:); data];
%%
nzobs=length(obs.z);
di=ones(nzobs,nprofs)*NaN;

for i=1:nprofs,
    if isempty(find(isfinite(z(:,i)+data(:,i)))),
        di(:,i)=NaN*ones(size(obs.z));
    else
        di(:,i)=interp_r(z(:,i),data(:,i),obs.z);
    end
end
%%
romsfr.salt.z=obs.z*ones(1,nprofs);
romsfr.salt.data=di;
romsfr.salt.dist= ones(nzobs,1)*romsfr.salt.dist(1,:);