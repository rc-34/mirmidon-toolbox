#!/bin/bash

## PARAMETERS ##
gridfile="grids.nc"

outfile1="gol-buoys.ps"

if [ -f $outfile1 ]
	then
	rm $outfile1
fi

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."Buoys's location of the Gulf of Lions":WeSn

gmtset PAPER_MEDIA a4
gmtset Y_AXIS_TYPE ver_text
gmtset BASEMAP_TYPE fancy+
gmtset FRAME_WIDTH 0.08c
gmtset ANNOT_FONT_SIZE 8p
gmtset ANNOT_OFFSET_PRIMARY 0.1c
gmtset LABEL_FONT_SIZE 8p
gmtset LABEL_OFFSET 0.2c
gmtset D_FORMAT %8.8f
gmtset HEADER_FONT Helvetica
gmtset HEADER_FONT_SIZE 14p  # ou plus ou moins, mais  histoire que ça soit de taille plus raisonnable
gmtset HEADER_OFFSET 0.5c  
## END PARAMETERS ##

# Set envelope
#envelope="-R-51.4199981689/75.3700027466/-3.20000004768/83.2300033569"
envelope="-R-1/9/40/45"


# create buoys location points
cat > buoys.xy << EOF
 4.16250   43.41100  Espiguette
 3.77962   43.37102  Sete
 3.12500   42.91667  Leucate
 3.16767   42.48950  Banyuls
 4.64000   42.06000  MeteoFranceGOL
EOF

cat > buoys-labels.xy << EOF
 4.26250   43.3 8 0 1 0 s2
 3.87962   43.27 8 0 1 0 s3
 3.22500   42.82 8 0 1 0 s4
 3.26767   42.39 8 0 1 0 s5
 4.74000   41.96 8 0 1 0 s1
EOF

# basemap
psbasemap $paramJ $envelope -Bf1a2.5:longitude:/f2.5a5:latitude:/:."Buoys's location of the Gulf of Lions":WeSn -K -V >> $outfile1

# add coast
pscoast $paramJ $envelope -Df -G#d9bb7a -Bf1a2.5:longitude:/f2.5a5:latitude:/:."Buoys's location of the Gulf of Lions":WeSn -W1/0.2p,black,solid -N1/0.2p,#0000FF,solid -S#5BA0B8 -C0.1p,#5BA0B8,solid -K -O >> $outfile1 

# add grid points
pstext buoys-labels.xy -JM20c $envelope -K -O -V >> $outfile1
psxy buoys.xy -JM20c $envelope -S+0.4c -O -V >> $outfile1
#pstext buoys.xy -D0.5/0.5 -JM20c $envelope -S+0.4c -O -V >> $outfile1  ### POUR LA VERSION 5 utiliser -D

# To raster
ps2raster -Tg -E600 -P -A -D. $outfile1
