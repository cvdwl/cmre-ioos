# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import numpy as np
import seawater as sw
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
import netCDF4
import numpy.ma as ma
import seawater
%matplotlib inline
import iris

# <codecell>

url = 'http://scsrv26v:8080/thredds/dodsC/gliders/GL-20140608-zoe-MEDREP14depl001-grid-D.nc.ncml'

# <codecell>

tvar = iris.load_cube(url,'sea_water_potential_temperature')
print tvar

# <codecell>

nc = netCDF4.Dataset(url)

# <codecell>

ncv = nc.variables

# <codecell>

ncv.keys()

# <codecell>

print ncv['ctd_temp']

# <codecell>

lon = ncv['ctd_longitude'][:]
lat = ncv['ctd_latitude'][:]
z = ncv['ctd_depth'][:]
tvar = ncv['ctd_time']
tim = netCDF4.num2date(tvar[:],tvar.units)

# <codecell>

data = ncv['ctd_temp'][:]

# <codecell>

print ncv['ctd_temp']

# <codecell>

data = ma.masked_invalid(data,copy=True)
z = ma.masked_invalid(z,copy=True)

# <codecell>

data.min()

# <codecell>

dist, pha = sw.dist(lat, lon, units='km')

# <codecell>

dist.min()

# <codecell>

def plot_glider(lon,lat,z,tim, data, mask_topo=False, **kw):
    """Plot glider cube."""
    cmap = kw.pop('cmap', plt.cm.rainbow)
    
    
    dist, pha = sw.dist(lat, lon, units='km')
    dist = np.append(0, np.cumsum(dist))
    dist, z = np.broadcast_arrays(dist[..., None], z)
    """
    z_range = [z.min(), z.max()]
    data_range = [data.min(), data.max()]
    good = np.logical_and(data >= data_range[0], data <= data_range[1])
    data = ma.masked_where(~good, data)
    
    condition = np.logical_and(z >= z_range[0], z <= z_range[1])
    z = ma.masked_where(~condition, z)
    """   
    fig,ax = plt.subplots(figsize=(12,4))
    cs = ax.pcolor(dist, z, data, cmap=cmap, **kw)

    if mask_topo:
        h = z.max(axis=1)
        xm, hm = gen_topomask(h, lon, lat, dx=1., kind='linear')
        ax.plot(xm, hm, color='black', linewidth='1', zorder=3)
        ax.fill_between(xm, hm, y2=hm.max(), color='0.8', zorbathy_der=3)
    ax.invert_yaxis()
    ax.set_title('Glider track from {} to {}'.format(tim[0], tim[-1]))
    ax.set_ylabel('depth (m)')
    ax.set_xlabel('alongtrack distance (km)')

    return fig, ax, cs, dist

# <codecell>

fig, ax, cs, dist= plot_glider(lon,lat,z,tim,data, mask_topo=False)
plt.ylim((0,100))
ax.invert_yaxis()
plt.colorbar(cs)

# <codecell>

bathy_url='http://geoport.whoi.edu/thredds/dodsC/bathy/srtm30plus_v1.nc'

# <codecell>

#ox = [lon.min(), lat.min(), lon.max(), lat.max()]
box = [6.5, 38.5, 9.0, 41.0]

# <codecell>

def get_bathy(url,box):
    nc=netCDF4.Dataset(url)
    print "Source name: %s" % nc.title
    lon=nc.variables['lon'][:]
    lat=nc.variables['lat'][:]
    bi=(lon>=box[0])&(lon<=box[2])
    bj=(lat>=box[1])&(lat<=box[3])
    z=nc.variables['topo'][bj,bi]
    nc.close()
    lon=lon[bi]
    lat=lat[bj]
    return z,lon,lat

# <codecell>

bathy_z, bathy_lon, bathy_lat = get_bathy(bathy_url,box)

# <codecell>

fig = plt.figure(figsize=(6, 6))
ax = fig.add_axes([0.1, 0.15, 0.8, 0.8])
bathy_z = ma.masked_where(bathy_z>0,bathy_z)
# plot bathymetry
pc = ax.pcolormesh(bathy_lon,bathy_lat, bathy_z,
                   vmin=bathy_z.min(), vmax=0)
# plot glider path
plt.plot(lon,lat,'k-')
cb = plt.colorbar(pc)
cb.set_label('Depth [m]')
ax.set_aspect(1.0/np.cos(bathy_lat.min() * np.pi / 180.0))

