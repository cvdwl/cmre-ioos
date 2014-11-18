
infile='vla2000327091137'
outfile = [infile '.nc'];
[x]=read_file_vla(infile,0,[],[]);


delete(outfile)
struct2nc(x,outfile,'netcdf4_classic',6)

