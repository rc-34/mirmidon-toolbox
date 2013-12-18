#!/bin/bash

gridfile="grids.nc"
fluxfile="FLUX_EG4_201201.nc"
Xinc=0.03
Yinc=0.03

#minmax=`minmax ${gridfile}`
#minX=`echo ${minmax:2} | awk 'BEGIN {FS="/"} {print $1}'`
#maxX=`echo ${minmax:2} | awk 'BEGIN {FS="/"} {print $2}'`
#minY=`echo ${minmax:2} | awk 'BEGIN {FS="/"} {print $3}'`
#maxY=`echo ${minmax:2} | awk 'BEGIN {FS="/"} {print $4}'`
#envelope="$minX/$maxX/$minY/$maxY"
envelope="-R-51.4199981689/75.3700027466/-3.20000004768/83.2300033569"

#extract long/lat
grd2xyz -V ${gridfile}?medh.lon > longitude
grd2xyz -V ${gridfile}?medh.lat > latitude 
grd2xyz -V ${fluxfile} > flux

join longitude latitude > temp
join temp flux > joined.xyz
awk '{ print  $3" "$5" "$7}' joined.xyz > grid.xyz

#interpolation
nearneighbor -V grid.xyz $envelope -I${Xinc}/${Yinc} -N4/2 -S1 -Ggrid_without_mask.grd
#xyz2grd grid.xyz -R-51.4199981689/75.3700027466/-3.20000004768/83.2300033569 -GextGrid.nc -I1

#1 to land / Nan to water
grdlandmask -V $envelope -Df -I${Xinc}/${Yinc} -N1/NaN -Gland_mask.grd 
#grdmath masks.nc?medh.msk INV = temp1.nc
#grdmath temp1.nc ISNAN = temp2.nc
#grdmath temp2.nc INV = inv_mask.nc

# apply mask
grdmath -V grid_without_mask.grd land_mask.grd OR = masked_flux.grd 
