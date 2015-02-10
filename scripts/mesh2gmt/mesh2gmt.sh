#!/bin/bash

#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

## PARAMETERS ##

work="work"
bathy="inputs/sirocco.europe.grd"
flux="inputs/MEDNORD20111101.nc"
studiedareaenvelope="inputs/studiedarea.dat"

outfile="outputs/zoom-mesh"
if [ -f $outfile ] ; then
	rm $outfile
fi

palette=/Users/rchailan/Applications/GMT-color-palette/bathy-ocean.cpt
palette="inputs/shallow-water.cpt"
#if [ ! -f $palette ] ; then
	#gmt makecpt -Z-3000/0/25 -Csealand -G-3000/0 > $palette
	gmt makecpt -Z-500/0/50 -Csealand -G-5000/0 -M -N > $palette
	log $? "create palette"
#fi

projection=-JM20c
paramB=-Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Bathymetry(m) - Gulf of Lions ":WeSn
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
gmt gmtset COLOR_BACKGROUND  50/50/20
gmt gmtset COLOR_FOREGROUND 105/105/105
gmt gmtset COLOR_NAN 255/255/255
## END PARAMETERS ##

# Set envelope
#envelope="-R2/6.80/41.30/43.70"
envelope="-R3/5/42.25/43.60" #envelope considered for fitmaxstab v1
#envelope="-R-5/17/32/45"



## PROCESS GRID POINTS FROM WW3-4.18 ounf outputs ##
#lon 
ncks -v longitude $flux |sed '1,11d'  > $work/longitude.ncks
awk '{print $1"="$2}' $work/longitude.ncks > $work/longitude.ncks2
awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/longitude.ncks2 > $work/longitude
log $? "long extraction"

#lat
ncks -v latitude $flux |sed '1,11d'  > $work/latitude.ncks
awk '{print $1"="$2}' $work/latitude.ncks > $work/latitude.ncks2
awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/latitude.ncks2 > $work/latitude
log $? "lat extraction"

join $work/longitude $work/latitude > $work/lonlat.xy
awk  '{print $2"	"$3}' $work/lonlat.xy > $work/nodes.xy
log $? "join node in a lonlat file"

## PLOT ##
gmt grdgradient $bathy $envelope -G$work/gradient.grd -A45 -Nt0.7 -V
log $? "grdgradient" 

gmt	grdimage $bathy $projection $envelope -C$palette -I$work/gradient.grd -P -K -V > ${outfile}.ps
log $? "grdimage"

awk '{ if ($4 >= 1.00) {print $2" "$3" "$4} }'  inputs/nodes.msh > $work/extratednodes.xyz
gmt triangulate $work/extratednodes.xyz -M -s3 > $work/network.xy
log $? "triangulate"

gmt psxy $envelope $projection $work/network.xy -Wthinner -P -K -O  -V >> ${outfile}.ps
log $? "psxy mesh"

gmt pscoast -V $projection $envelope -Df -G#d9bb7a -C#d9bb7a -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

# gmt	psxy $studiedareaenvelope $projection $envelope  -W0.9 -L -P -K -O >> ${outfile}.ps
# log $? "psxy"

gmt	psbasemap $envelope $projection -Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Mesh zoom - Gulf of Lions ":WeSn -P -O >> ${outfile}.ps
# gmt	psbasemap $envelope $projection -Bf2a4:longitude:/f1a2:latitude:/:."Computational mesh - Gulf of Lions ":WeSn -P -O >> ${outfile}.ps
log $? "psbasemap"


gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"



