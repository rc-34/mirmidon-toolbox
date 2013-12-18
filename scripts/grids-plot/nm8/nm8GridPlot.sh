#!/bin/bash

## PARAMETERS ##
gridfile="grids.nc"
fluxfile="vomecrty.nc"

outfile1="nm8Grid.ps"
rm $outfile1

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."NM8-24 Original Grid":WeSn

gmtset PAPER_MEDIA a4
gmtset Y_AXIS_TYPE ver_text
gmtset BASEMAP_TYPE fancy+
gmtset FRAME_WIDTH 0.08c
gmtset ANNOT_FONT_SIZE 8p
gmtset ANNOT_OFFSET_PRIMARY 0.1c
gmtset LABEL_FONT_SIZE 8p
gmtset LABEL_OFFSET 0.2c
gmtset D_FORMAT %8.8f
## END PARAMETERS ##

# Set envelope
#envelope="-R--20.92985725/36.25000000/22.99697876/45.72526932"
 envelope="-R-20/50/28/53"


# extract long/lat
grd2xyz -V  ${fluxfile}?nav_lon > xylon
grd2xyz -V  ${fluxfile}?nav_lat > xylat
grd2xyz -V  ${fluxfile}?vomecrty > xyvomecrty
join xylon xylat > temp
join temp xyvomecrty > joined.xyz


# grd2xyz -V ${gridfile}?medh.lon > longitude
# grd2xyz -V ${gridfile}?medh.lat > latitude 
# grd2xyz -V ${fluxfile}?TSUR > flux

# join longitude latitude > temp
# join temp flux > joined.xyz
awk '{ print  $3" "$5" "$7}' joined.xyz > grid.xyz

# # basemap
psbasemap $paramJ $envelope -Bf5a10:longitude:/f2.5a5:latitude:/:."NM8 original Grid (zoom)":WeSn -K -V >> $outfile1

# add coast
pscoast $paramJ $envelope -Dl -G#d9bb7a -Bf5a10:longitude:/f2.5a5:latitude:/:."NM8 original Grid (zoom)":WeSn -W1/0.2p,black,solid -N1/0.2p,#0000FF,solid -S#5BA0B8 -C0.1p,#5BA0B8,solid -K -O >> $outfile1 

# add grid points
psxy grid.xyz -JM20c $envelope -Sp -O -V >> $outfile1

# To raster
# ps2raster -Tg -E600 -P -A -D. $outfile1

# Clean folder
#rm -f $outfile1