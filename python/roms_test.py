# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <headingcell level=1>

# ROMS Test

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

url='http://scsrv26v:8080/thredds/dodsC/cmre_roms/fmrc/cmre_roms_best.ncd'

# <codecell>

tvar = iris.load_cube(url,'potential temperature')

# <codecell>

print tvar

# <codecell>

print tvar[-1,0,0,0]

# <codecell>

tim.convert_units()

# <codecell>


