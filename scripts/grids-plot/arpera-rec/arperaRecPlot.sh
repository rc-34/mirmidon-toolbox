#!/bin/bash

## PARAMETERS ##
gridfile="grids.nc"
fluxfile="UX10-000.grd"

outfile1="arperaRecGrid.ps"
rm $outfile1

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera regular Grid ":WeSn

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
#envelope="-R-51.4199981689/75.3700027466/-3.20000004768/83.2300033569"
envelope="-R-20/50/28/53"

grd2xyz -V ${fluxfile}?UX10[0] > grid.xyz


# basemap
psbasemap $paramJ $envelope -Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera regular Grid ":WeSn -K -V >> $outfile1

# add coast
pscoast $paramJ $envelope -Dl -G#d9bb7a -Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera regular Grid ":WeSn -W1/0.2p,black,solid -N1/0.2p,#0000FF,solid -S#5BA0B8 -C0.1p,#5BA0B8,solid -K -O >> $outfile1 

# add grid points
psxy grid.xyz -JM20c $envelope -Sp0.01c -O -V >> $outfile1

# To raster
ps2raster -Tg -E600 -P -A -D. $outfile1

# Clean folder
#rm -f $outfile1