function x = read_file(filename, offset, length, cha )
%***************************************************************
%*
%* x = read_file(filename, offset, length, cha )
%*
%* Read HLA , MFA , VLA , DUSS data files in SACLANT format
%*
%*    filename = ASCII filename
%*    offset   = reading time offset (s)
%*    length   = reading length (s)
%*    cha      = vector with selected channels to read
%*
%*    x        = output structure
%*               x.t_s  (samples, cha)  data matrix
%*               x.t_ax time x axis
%*               x.vga  (8)  Variable gain amplifiers dB
%*               x.pre  Preamplifier gain dB
%*               x.eq   High Pass Frequency  Hz
%*               x.t    Date , time
%*
%* c=read_file(filename)   offset=0
%*                         length= total file length
%*                         cha = all channels        
%*                         endian = type found in the header
%*
%* c=read_file(filename,[],2,[1 4 10])
%*                         offset = 0
%*                         length = 2 s
%*                         cha = channels 1,4, 10 selected
%*                         endian = type found in the header
%***************************************************************


endian='n';
if nargin < 2
     offset=[];
     length=[];
     cha = [];
end
if nargin < 3
     length=[];
     cha=[];
end
if nargin < 4
     cha = [];
end

[fid, message] = fopen(filename, 'r');
if fid == -1
     fprintf(2, '%s\n', message)
     return
end
hyd_id=cha;
x.cha = cha;
x.t = [];
x.vga = [];
x.pre = [];
x.eq = [];
vla_lat=0;
vla_lon=0;
while 1
     s = char(fread(fid, [1, 80]));
     if strncmp(s, 'END', 3)
          break
     elseif strncmp(s, 'TIME', 4)
          x.t = s(7:29);
     elseif strncmp(s, 'NRHE', 4)
          nrhe = sscanf(s, '%*s%f');
     elseif strncmp(s, 'JDAY', 4)
          x.jday = sscanf(s, '%*s%d');
     elseif strncmp(s, 'RECL', 4)
          recl = sscanf(s, '%*s%f');
     elseif strncmp(s, 'NCHA', 4)
          ncha = sscanf(s, '%*s%f');
     elseif strncmp(s, 'FOUT', 4)
          x.fout = sscanf(s, '%*s%f');
     elseif strncmp(s, 'CONV', 4)
          conv = sscanf(s, '%*s%f');
     elseif strncmp(s, 'DSIZE', 5)
          dsize = sscanf(s, '%*s%d');
     elseif strncmp(s, 'DELAY', 5)
          x.delay = sscanf(s, '%*s%f');
     elseif strncmp(s, 'DTYP', 4)
          dtype = sscanf(s(11:11), '%d');
     elseif strncmp(s, 'CPU ', 4)
          dendian = sscanf(s, '%*s%s');
          endian='l';
          if strncmp(dendian(1:2) , 'HP', 2)
             endian = 'b';
          end
     elseif strncmp(s, 'IMS', 3)
          s1 = [];
          while 1
               s = fread(fid, [1, 80]);
               if strncmp(sscanf(char(s), '%s'), 'IMSEND', 6)
                    ind=find(char(s1) == ',');
                    s1(ind)=32;
                    lat = sscanf(char(s1(36:46)), ['%f%f']); 
                    lon = sscanf(char(s1(49:59)), ['%f%f']);
                    sspeed = sscanf(char(s1(70:79)), ['%f%f']);
                    if(numel(lat)<2 | numel(lon)<2)
                      x.lat=0;
                      x.lon=0;
                    else
                      x.lat=lat(1)+lat(2)/60;
                      x.lon=lon(1)+lon(2)/60;
                    end
		    if(numel(sspeed)<2)
                      x.speed=0;
                      x.course=0;
                    else
                      x.sspeed=sspeed(1);
                      x.course=sspeed(2);
                    end
		    x.wat_dep=sscanf(char(s1(81:86)), ['%f']);
                    break
               else
                    s1 = [s1, s];
               end
          end
     elseif strncmp(s, 'NAD', 3)
          s1 = [];
          while 1
               s = fread(fid, [1, 80]);
               if strncmp(sscanf(char(s), '%s'), 'NADEND', 6)
                    x.atlas_depth = sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%f']);
                    x.atlas_depth=x.atlas_depth(1);
                    tnad = sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%*s%*s%*s%*s%*s%*s%*f%*f%*f%*f', ...
                         '%*f%*f%*f%*f%*s%s%*s%*s%*s%*s%*s%*s']);
                    t = sscanf(char(s1(find(s1))), ...
                         ['%*s%f:%f:%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s', ...
                         '%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s']);
                    vga = sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%*s%*s%*s%*s%*s%*s%f%f%f%f', ...
                         '%f%f%f%f%*s%*s%*s%*s%*s%*s%*s%*s']);
                    x.vga = vga;
                    x.pre = [x.pre, sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s', ...
                         '%*s%*s%*s%*s%*s%*s%*s%*s%f%*s%*s%*s'])];
                    if(strncmp(tnad,'T_NAD',5))
                         x.eq = sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s', ...
                         '%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%f']);
                    else
                         x.eq = sscanf(char(s1(find(s1))), ...
                         ['%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s', ...
                         '%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%f%*s']);
                    end
                    break
               else
                    s1 = [s1, s];
               end
          end
     elseif strncmp(s, 'WARIN', 5)
          while 1
               s = fread(fid, [1, 80]);
               if strncmp(sscanf(char(s), '%s'), 'WARINEND', 8)
                    break
               end
          end
     elseif strncmp(s, 'TMARK', 5)
          m = [];
          while 1
               s = char(fread(fid, [1, 80]));
               if strncmp(sscanf(s, '%s'), 'TMARKEND', 8)
                    break
               else
                    m = [m, sscanf(s, '%*s%d')];
               end
          end
     end
end
fclose(fid);
%x.tmark=m;
if vla_lat ~= 0
   x.lat=vla_lat;
   x.lon=vla_lon;
end
if isempty(cha)
   cha=[1:ncha];
   hyd_id=cha;
   x.cha = cha;
end
n=0;
nsh=size(cha,2);
for i=1:nsh
   n=n+1;
   ind=find(cha(i) == hyd_id);
   cha_ind(n)=ind(1);
end
cha_ind=hyd_id(cha_ind);
maxlen=dsize/dtype/x.fout;
if isempty(offset) 
   offset=0;
end 
if isempty(length)
   length=maxlen-offset;
end 
if (length +offset) > maxlen
   length=maxlen-offset;
end
if offset < 0
   offset=0;
end
[fid, message] = fopen(filename, 'r', endian);
%[fid, message] = fopen(filename, 'r');
if fid == -1
     fprintf(2, '%s\n', message)
     return
end
dform='short';
if dtype == 4
   dform='long';
end
x.t_s = [];
block_l = fix(x.fout*length);
block_o = fix(x.fout*offset);
     x.header=fread(fid,nrhe*recl,'char');
     x.nrhe=nrhe;
     x.recl=recl;
     fseek(fid, nrhe*recl+dtype*block_o*ncha-dtype, 'bof');
     tmp = fread(fid, 2*ncha, dform);
     i2 = find(rem(tmp, 2));
     if isempty(i2)
          x.t_s = [x.t_s; zeros(1, block_l)];
     else
          fseek(fid, nrhe*recl+dtype*block_o*ncha+dtype*i2(end)-dtype*2, 'bof');
          tmp = fread(fid, [ncha, block_l], dform);
%          i2 = find(rem(tmp(1, :), 2) == 0);
%          if ~isempty(i2)
%               x.t_s = [x.t_s; tmp(hyd_id, 1:i2(1)-1)]';
%          else
%               x.t_s = [x.t_s; tmp(hyd_id, :)]';
%          end
           x.t_s=tmp(hyd_id,:)';
     end
x.t_s = x.t_s/conv;

x.t_ax =(offset+((1:size(x.t_s,1))-1)/x.fout)';
fclose(fid);
