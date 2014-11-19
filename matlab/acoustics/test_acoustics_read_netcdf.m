url='http://scsrv26v:8080/thredds/dodsC/models/acoustics/vla2000327091137.nc';
channel = 23;
t_s = ncread(url,'t_s',[1 channel],[Inf,1]);
plot(t_s)
shg()
