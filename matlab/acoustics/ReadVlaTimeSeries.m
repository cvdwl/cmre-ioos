clear all; close all;

pathname='/media/EXT DATA Glass1/MAPEX2K/';

d=dir([pathname 'vla*']);

istart=1;
filename=[pathname,d(istart).name];

x=read_file_vla([filename],0,0.1,1);


%FileTime=str2num(d(iifile1).name(end-13:end-12))+str2num(d(iifile1).name(end-10:end-9))/60+ ...
%  str2num(d(iifile1).name(end-7:end-6))/3600;
FileTime=hms2h(str2num(x.t(end-10:end-9)),str2num(x.t(end-7:end-6)),str2num(x.t(end-4:end)));

tdata=[];
data=[];
datafilt=[];


Wn=[50 2000]/x.fout*2;
b = fir1(100,Wn,'bandpass');   % HP filter at 1/40th the nyquist frequen

depths = [62:-2:50 48:-1:40 39.5:-.5:24 23:-1:16 14:-2:0];
wd=120;
depths = depths + (wd-max(depths))-12;
depths=fliplr(depths);
dsize=2^12;
ip1=find(diff(depths)==0.5);
ip2=find(diff(depths)==1.0);
ip3=find(diff(depths)==2.0);
ip3=[ip3(1:8) ip2(1:2:8) ip1(1:4:end) ip2(9:2:end) ip3(9:end) length(depths)];
ip2=[ip2(1:8) ip1(1:2:end) ip2(9:end)];

ispc=0;
ifilt=1;
nblock=12;
mblock=20;
tdatapass=FileTime*3600;
for jj=1:mblock
  for ii=1:nblock
    indx=(jj-1)*nblock+ii;
    filename=[];
    filename=[pathname,d(indx).name];
    x=[];
    x=read_file_vla(filename,0,0.1,ip1(1));
    AllLon(indx)=x.lon;
    AllLat(indx)=x.lat;
    AllWd(indx)=x.wat_dep;
    tshade=costap(size(x.t_s,1),1,size(x.t_s,1),5)';
    txshade=detrend(x.t_s.*(tshade*ones(1,size(x.t_s,2))));
    data=[data;txshade]; 
    if(ifilt==1)
      txfiltshade=filtfilt(b,1,txshade);
      datafilt=[datafilt;txfiltshade];
    end
    if(isempty(tdata))
      tdata=[tdata x.t_ax.'+tdatapass];
      dtax=x.t_ax(2);
    elseif(~isempty(tdata))
      tdata=[tdata x.t_ax.'+tdata(end)+dtax];
      tdatapass=tdata(end);
    end
  end

  disp(['Outer block No: ',num2str(jj),' out of ',num2str(mblock)]);

end

break

% MAPEX2BIS at site 1 on Malta Plateau (Day of Year 327)
vla=[14+46.535/60 36+26.673/60];
vla1=[14+46.434/60 36+26.329/60];

figure
plot(AllLon,AllLat,'k-','linewidth',2)
hold on
plot(vla(1),vla(2),'ro')
hold off

for ii=1:length(AllLon)
  rng(ii)=rngdaniella([vla(2) AllLat(ii)],[vla(1) AllLon(ii)]);
end

figure
plot(rng,AllWd,'k-','linewidth',2)

