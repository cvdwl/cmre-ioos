clear all; close all;

% Information on CD 2167C CD-ROM 43 MAPEX2KBIS
% Data recorded on 22 Nov 2000 Start time 8:51-9:36
% VLA position 14.7755833 36.44455
%pathname='/media/EXT DATA Glass1/MAPEX2K/';
pathname='/media/EXT DATA2 glass/MAPEX2K/';

d=dir([pathname 'vla*']);

istart=1;
filename=[pathname,d(istart).name];

x=read_file_vla([filename],0,0.1,1);


%FileTime=str2num(d(iifile1).name(end-13:end-12))+str2num(d(iifile1).name(end-10:end-9))/60+ ...
%  str2num(d(iifile1).name(end-7:end-6))/3600;
FileTime=hms2h(str2num(x.t(end-10:end-9)),str2num(x.t(end-7:end-6)),str2num(x.t(end-4:end)));

data=[];
tdata=[];
dataresamp=[];

spcdata=[];
tdata=[];
datatmp=[];
cov=[];

nblock=12;
mblock=floor(length(d)/nblock);

Wn=[50 2000]/x.fout*2;
b = fir1(100,Wn,'bandpass');   % HP filter at 1/40th the nyquist frequen

depths = [62:-2:50 48:-1:40 39.5:-.5:24 23:-1:16 14:-2:0];
wd=120;
depths = depths + (wd-max(depths))-12;
depths=fliplr(depths);
dsize=2^7;
ip1=find(diff(depths)==0.5);
ip2=find(diff(depths)==1.0);
ip3=find(diff(depths)==2.0);
ip3=[ip3(1:8) ip2(1:2:8) ip1(1:4:end) ip2(9:2:end) ip3(9:end) length(depths)];
ip2=[ip2(1:8) ip1(1:2:end) ip2(9:end)];

ispc=0;
ifilt=1;
% nblock=12 signals bad when mblock~12
mblock=1;
nblock=144
tdatapass=FileTime*3600;
for jj=1:mblock
  tdata=[];
  data=[];
  datafilt=[];
  for ii=1:nblock
    indx=(jj-1)*nblock+ii;
    filename=[];
    filename=[pathname,d(indx).name];
    x=[];
    x=read_file_vla(filename,0,[],ip1);
    AllLon(indx)=x.lon;
    AllLat(indx)=x.lat;
    WatDep(indx)=x.wat_dep;
    tshade=costap(size(x.t_s,1),1,size(x.t_s,1),5)';
    txshade=detrend(x.t_s.*(tshade*ones(1,size(x.t_s,2))));
    data=[data;txshade]; 
    if(ifilt==1)
      txfiltshade=filtfilt(b,1,txshade);
      datafilt=[datafilt;txfiltshade];
    end
    if(ispc==1)
      dfrr=x.fout/dsize;
      frr=linspace(0,x.fout-dfrr,dsize);
      VLASyn=vsystsen(x.pre,x.vga(1),x.eq,frr(1:dsize/2+1));
      RVLASyn=10.^(-VLASyn/20);
      en1=sum(txshade(1:dsize,1).^2)/x.fout;
      en2=sum(abs(fft(txshade(1:dsize,1)/x.fout)).^2)*dfrr;
      en1/en2
      spc=[];
      spc=abs(fft(txshade(1:dsize,1)/x.fout)).';
      figure(100)
%      plot(frr(1:dsize/2+1),20*log10(RVLASyn.*spc(1:dsize/2+1)),'k-')
      semilogx(frr(1:dsize/2+1),20*log10(RVLASyn.*spc(1:dsize/2+1)),'k-')
      hold on
      spc=[];
      spc=abs(fft(txfiltshade(1:dsize,1)/x.fout)).';
%      plot(frr(1:dsize/2+1),20*log10(RVLASyn.*spc(1:dsize/2+1)),'r-')
      semilogx(frr(1:dsize/2+1),20*log10(RVLASyn.*spc(1:dsize/2+1)),'r-')
      hold off
      nfft=256;
      [spcdatatmp,f,t]=calspecgram(txfiltshade(1:end,1),nfft,x.fout,ones(nfft,1),0);
%     Divide by sqrt(T)=sqrt(nfft/Fs) to match Pxx from pwelch (definition of power spectrum
      spcdatatmp=spcdatatmp/sqrt(nfft/x.fout);
%     Check sum of time and frequency domain data
      enfs=sum(2*(abs(spcdatatmp).^2))*(f(2)-f(1));
      VVLASyn=vsystsen(x.pre,x.vga(1),x.eq,f);
      RRVLASyn=10.^(-VVLASyn/20);
      figure(101)
      pcolor(t,f,20*log10((RRVLASyn(:)*ones(1,length(t))).*abs(spcdatatmp)));shading('flat');caxis([0 100]);colorbar;
      xlabel(['Time (s)']);
      ylabel(['Frequency (Hz)']);
    end
    if(isempty(tdata))
      tdata=[tdata x.t_ax.'+tdatapass];
      dtax=x.t_ax(2);
    elseif(~isempty(tdata))
      tdata=[tdata x.t_ax.'+tdata(end)+dtax];
      tdatapass=tdata(end);
    end
  end
%keyboard
  disp(['Outer block No: ',num2str(jj),' out of ',num2str(mblock)]);
  HydrPow(:,jj)=(sum(data.^2,1).')/nblock;
  HydrPowFilt(:,jj)=(sum(datafilt.^2,1).')/nblock;
  [cov,fr] = Make_CSDMatrix_RL(flipud(data'),x.fout,dsize);
  [covfilt,fr] = Make_CSDMatrix_RL(flipud(datafilt'),x.fout,dsize);

  figure(1)
  subplot(2,2,1)
  iff=find(abs(fr-300)==min(abs(fr-300)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,2)
  iff=find(abs(fr-600)==min(abs(fr-600)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,3)
  iff=find(abs(fr-800)==min(abs(fr-800)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,4)
  iff=find(abs(fr-1200)==min(abs(fr-1200)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  drawnow

  [Noise_RL,theta,bf_out,phi] =  Make_RL(cov,fr,depths(ip1),1,'H',0);
  figure(2)
  pcolor(fr,phi,10*log10(bf_out));shading('flat');caxis([40,100]);axis([100,1500,-90,90])
  set(gca,'Fontsize',14);xlabel('Frequency (Hz)');ylabel('Vertical Beam Angle (Deg)')
  titletxt=['Beamform VLA MAPEX2K: ',num2str(mblock)];
  title(titletxt)
  drawnow

  figure(3)
  pcolor(theta,fr,Noise_RL');shading('flat');caxis([0,10]);colorbar;axis([0,90,100,1500])
  set(gca,'Fontsize',14);xlabel('Grazing Angle (Deg)');ylabel('Frequency (Hz)')
  titletxt=['Bottom Loss VLA MAPEX2K: ',num2str(jj)];
  title(titletxt)
  drawnow

  itskip=800;
  [tm,coh_noise_ts] = Coh_Noise_TS(cov,fr,x.fout,depths(ip1),dsize,100,1500,1,0);
  hilb_coh_noise_ts=abs(hilbert(coh_noise_ts));
  ProfD(jj,:)=hilb_coh_noise_ts(itskip:end)/max(hilb_coh_noise_ts(itskip:end));
  ProfT(jj,:)=tm(itskip:end)*1500/2;
  figure(4)
  plot(ProfD(jj,:),ProfT(jj,:),'k-','linewidth',2);
  axis([0 1.2 100 250]);
  set(gca,'ydir','reverse')
  ylabel('Depth (m)');
  xlabel('Fath. return (au)')
  drawnow

%  eval(['save VLA_Nblock144Mblock',num2str(jj),' fr depths ip1 b cov covfilt theta phi bf_out Noise_RL']);


   save MAPEX2KBIS_Cov_05Apterure_Dsize2to7 cov covfilt depths ip1 fr 

%  pause

end

break

eval(['save PROF_VLA_Nblock144Mblock',num2str(jj),' ProfD ProfT HydrPow HydrPowFilt d']);

break

for ii=1:1
%  eval(['load VLA_Nblock12Mblock',num2str(ii)]);
  eval(['load VLA_Nblock144Mblock1']);

  figure(1)
  subplot(2,2,1)
  iff=find(abs(fr-300)==min(abs(fr-300)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,2)
  iff=find(abs(fr-600)==min(abs(fr-600)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,3)
  iff=find(abs(fr-800)==min(abs(fr-800)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  subplot(2,2,4)
  iff=find(abs(fr-1200)==min(abs(fr-1200)));
  pcolor(depths(ip1),depths(ip1),squeeze(abs(cov(:,:,iff))));shading('flat');
  set(gca,'ydir','reverse');
  title(['F= ',num2str(fr(iff)),' Hz'])
  drawnow

  figure(2)
  pcolor(fr,phi,10*log10(bf_out));shading('flat');caxis([40,100]);axis([100,1500,-90,90])
  set(gca,'Fontsize',14);xlabel('Frequency (Hz)');ylabel('Vertical Beam Angle (Deg)')
  titletxt=['Beamform VLA MAPEX2K: ',num2str(ii)];
  title(titletxt)
  drawnow
  
  figure(3)
  pcolor(theta,fr,Noise_RL');shading('flat');caxis([0,10]);colorbar;axis([0,90,100,1500])
  set(gca,'Fontsize',14);xlabel('Grazing Angle (Deg)');ylabel('Frequency (Hz)')
  titletxt=['Bottom Loss VLA MAPEX2K: ',num2str(ii)];
  title(titletxt)
  drawnow

  pause(0.5)

end

break

figure(1)
clf
load VLA_Nblock144Mblock1.mat
subplot(2,2,1)
pcolor(theta,fr,Noise_RL');shading('flat');caxis([0,10]);
hh=get(gca,'position');
%colorbar;axis([0,90,100,1500])
colorbar;axis([0,90,0,2000])
set(gca,'position',[hh(1)-.01 hh(2) hh(3)-0.05 hh(end)])
set(gca,'Fontsize',12);xlabel('Grazing Angle (Deg)');ylabel('Frequency (Hz)')
titletxt=[];
titletxt=['Bottom Loss MAPEX2KBIS'];
title(titletxt)
drawnow
set(gcf,'Renderer','zbuffer');

load PROF_VLA_Nblock144Mblock1.mat
subplot(2,2,2)
plot(ProfD,ProfT,'k-','linewidth',2)
kk=get(gca,'position');
set(gca,'ydir','reverse');set(gca,'fontsize',12);
set(gca,'position',[kk(1)+0.1 kk(2) kk(3)-0.1 kk(4)])
axis([0 1.2 100 220]);
xlabel('Fath. return (au)')
ylabel('Depth (m)');
titletxt=[];
titletxt=['Fathometer MAPEX2KBIS'];
title(titletxt)
set(gcf,'Renderer','zbuffer');

iprof=0;

if(iprof==0)
  load PROF_VLA_Nblock144Mblock1.mat
  figure
  plot(ProfD,ProfT,'k-','linewidth',2)
  set(gca,'ydir','reverse')
  axis([0 1.2 100 220]);
  xlabel('Fath. return (au)')
  ylabel('Depth (m)');
elseif(iprof==1)
  load PROF_VLA_Nblock12Mblock20.mat
  figure
  subplot(2,2,1)
  pcolor([1:20],ProfT(1,:),20*log10(ProfD'));shading('flat');caxis([-40 -10]);colorbar
  axis([0 20 100 150])
  set(gca,'ydir','reverse');
  xlabel('No of 2 min snapshots')
  ylabel('Depth (m)')

  subplot(2,2,2)
  pcolor(20*log10(HydrPow));shading('flat');caxis([90 100]);colorbar
  set(gca,'ydir','reverse')
  subplot(2,2,3)
  pcolor(20*log10(HydrPowFilt));shading('flat');caxis([80 90]+4);colorbar
  set(gca,'ydir','reverse')
end

break

% MAPEX2BIS at site 1 on Malta Plateau (Day of Year 327)
vla=[14+46.535/60 36+26.673/60];
vla1=[14+46.434/60 36+26.329/60];

iff=512;
pcolor(depths(ip1),depths(ip1),20*log10(abs(cov(:,:,iff))));shading('flat');colorbar
set(gca,'ydir','reverse');
title(['Frequency ',num2str(fr(iff)),' Hz']);
xlabel('Depth (m)')
ylabel('Depth (m)')


break


%  fdata=[fdata fdatatmp'];
%  Fourth argument in calspecgram is the window applied to the time series; here unit amplitude and flat
  nfft=2*16*256;
%  [spcdatatmp,f,t]=calspecgram(datatmp(1:nfft),nfft,Fs,ones(nfft,1),nfft/2);caxis([-100 -20]);colorbar
   [spcdatatmp,f,t]=calspecgram(datatmp,nfft,Fs,ones(nfft,1),0);caxis([-100 -20]);colorbar
% Divide by sqrt(T)=sqrt(nfft/Fs) to match Pxx from pwelch (definition of power spectrum
  spcdatatmp=spcdatatmp/sqrt(nfft/Fs);
% Check sum of time and frequency domain data
  enfs=sum(2*(abs(spcdatatmp).^2))*(f(2)-f(1))
% Straight FFT needs to divide by Fs in order to get the same energy level in time and frequency domain
  spectrum=fft(datatmp(1:nfft)/Fs,nfft)/sqrt(nfft/Fs);
  df=Fs/nfft;
  ent=sum(abs(datatmp(1:nfft)).^2)/Fs
  enf=sum(abs(spectrum).^2)*df

% 
  [Pxx(:,ii),F]=pwelch(datatmp(1:nfft),ones(nfft,1),0,nfft,Fs);
  plot(F,10*log10(Pxx(:,ii)),'k-')
  hold on
  plot(f,20*log10(2*abs(spcdatatmp(:,end))),'r-')   
  plot(f,20*log10(2*abs(spectrum(1:nfft/2+1))),'g--')
  hold off

  fmin=50;
  fmax=20000;
  ifrqmin=find(abs(f-fmin)==min(abs(f-fmin)));
  ifrqmax=find(abs(f-fmax)==min(abs(f-fmax)));
  frqdata=f(ifrqmin:2:ifrqmax);
  IntLavgdB=interp1(fHz,10.^(lavgdB/20),frqdata);
  IntLavgdBPxx=interp1(fHz,10.^(lavgdB/10),F);

% pwelch and my version of calspecgram agree 
% if the calspecgram routine is called with datatmp(1:nfft), i.e. the same size data as the pwelch
  Pxx(:,ii)=Pxx(:,ii)./IntLavgdBPxx;
  spcdata=[spcdata abs(spcdatatmp(ifrqmin:2:ifrqmax,:))./(IntLavgdB*ones(1,size(spcdatatmp,2)))];

  fprintf(' Block %d out of %d \r',ii,nblock)

%  spectrogram(fdata(i1:i2,4),4*256,2*128,4*128*2,100000);caxis([-140 -90]+20);colorbar
%  calspecgram(fdata(i1:i2,2),16*256,100000,ones(length(datatmp),1));caxis([-100 -20]);colorbar
%  calspecgram(data(i1:i2,2),16*256,100000,ones(length(datatmp),1));caxis([-100 -20]);colorbar

   figure(1)
   semilogx(frqdata/1000,20*log10(2*runmean(spcdata(:,end),10,1)),'k-','linewidth',2)
   hold on
   semilogx(F/1000,10*log10(runmean(Pxx(:,ii),20,1)),'r-','linewidth',2)
   hold off
   axis([0.5 20 30 70])
   set(gca,'fontsize',14)
   xlabel('Frequency (kHz)')
   ylabel('Power Spectral Density (dB re 1\muPa^2/Hz)')
   title('Noise level');

break

scale=1;
for ii=1:8
  figure(1);
  plot([0:size(dataresamp,2)-1]/Fs2/3600+FileTime,scale*dataresamp(ii,:)+ii,'k-','linewidth',2);
  axis([FileTime (size(dataresamp,2)-1)/Fs2/3600+FileTime 0 9]);
  hold on
end

break
% Low pass filter to sea sea surface 
ts=resample(data,1,100);
Fs2=1000;
nn=1500;
[b]=fir1(nn,0.5/Fs2,'low');
nfft2=2^20;
fax=[0:nfft2-1]*Fs2/nfft2;
%plot([0:nfft2-1]/Fs,runmean(data(1:nfft2),500)*exp(169/20),'k-')
filts=filtfilt(b,1,ts);
plot([0:length(filts)-1]/Fs2,ts*10^(169/20)*1e-6,'r-')
hold on
plot([0:length(filts)-1]/Fs2,filts*10^(169/20)*1e-6,'k-')
hold off

   figure(1)
%  imagesc(IntRng,frqdata,20*log10(spcdata),[-50 10]);colorbar
   pcolor(tdata/3600,frqdata/1000,20*log10(runmean(spcdata,5,2)));shading('flat');caxis([30 100]);colorbar
%   pcolor((1.852*9.6*(tdata-tdata(1))/3600-1.05)*1000,frqdata,20*log10(runmean(spcdata,5,2)));shading('flat');caxis([-50 10]);colorbar
   set(gca,'ydir','normal');
%   axis([-500 500 50 5000]);
   set(gca,'fontsize',14)
%   xlabel('Range to CPA (m)')
   xlabel('UTC (h)')
   ylabel('Frequency (kHz)')
%   title('eFOLAGA moored; pass by NRV Alliance');
   title('Power Spectral Density (dB re 1\muPa^2/Hz)');

figure(2)

vardB=var(20*log10(spcdata(:,:)),[],2);
stddB=std(20*log10(spcdata(:,:)),[],2);
vardB=20*log10(var(spcdata(:,:),[],2));
stddB=20*log10(std(spcdata(:,:),[],2));
semilogx(frqdata/1000,20*log10(mean(spcdata(:,:),2)),'k-','linewidth',2)
hold on
semilogx(frqdata/1000,20*log10(var(spcdata(:,:),2)),'r-','linewidth',2)

