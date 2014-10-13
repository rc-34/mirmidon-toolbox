#!/bin/bash

## PARAMETERS ##
gridfile="grids.nc"
fluxfile="flux_without_mask.grd"

outfile1="arperaREC.ps"
rm $outfile1

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera REC Grid ":WeSn

gmt gmtset PS_MEDIA a3
gmt gmtset MAP_ANNOT_ORTHO ver_text
gmt gmtset MAP_FRAME_TYPE fancy+
gmt gmtset MAP_FRAME_WIDTH 0.08c
gmt gmtset FONT_TITLE Helvetica
gmt gmtset FONT_TITLE 14p
gmt gmtset MAP_TITLE_OFFSET 0.3c
gmt gmtset FONT_LABEL 8p
gmt gmtset MAP_LABEL_OFFSET 0.2c
gmt gmtset FORMAT_FLOAT_OUT %8.8f
## END PARAMETERS ##

# Set envelope
envelope="-R-8/20/28/48"

#extract long/lat
#grd2xyz -V ${fluxfile}?longitude > longitude
#grd2xy -V ${fluxfile}?latitude > latitude 
#grd2xyz -V ${fluxfile}?UX10 > flux

# basemap
gmt psbasemap $paramJ $envelope -Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera REC Grid ":WeSn -K -V >> $outfile1

# add coast
gmt pscoast $paramJ $envelope -Dl -G#d9bb7a -Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera REC Grid ":WeSn -W1/0.2p,black,solid -N1/0.2p,#0000FF,solid -S#5BA0B8 -C0.1p,#5BA0B8,solid -K -O >> $outfile1 

# add grid points
#psxy grid.xyz -JM20c $envelope -Sp0.05c -O -V >> $outfile1


# To raster
#ps2raster -Tg -E600 -P -A -D. $outfile1

# Clean folder
#rm -f $outfile1