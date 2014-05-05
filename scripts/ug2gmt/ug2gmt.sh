#!/bin/bash

#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

## PARAMETERS ##

work="work"
bathy="inputs/sirocco.europe.grd"
flux="inputs/MEDNORD20111101.nc"

outfile="outputs/GOLREG"
if [ -f $outfile ] ; then
	rm $outfile
fi

palette=/Users/rchailan/Applications/GMT-color-palette/bathy-ocean.cpt
palette="inputs/shallow-water.cpt"
if [ ! -f $palette ] ; then
	gmt makecpt -Z-3000/0/25 -Csealand -G-3000/0 > $palette
	log $? "create palette"
fi

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
## END PARAMETERS ##

# Set envelope
envelope="-R2/6.80/41.30/43.70"


## PROCESS GRID POINTS FROM WW3-4.18 ounf outputs ##
# #lon 
# ncks -v longitude $flux |sed '1,11d'  > $work/longitude.ncks
# awk '{print $1"="$2}' $work/longitude.ncks > $work/longitude.ncks2
# awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/longitude.ncks2 > $work/longitude
# log $? "long extraction"

# #lat
# ncks -v latitude $flux |sed '1,11d'  > $work/latitude.ncks
# awk '{print $1"="$2}' $work/latitude.ncks > $work/latitude.ncks2
# awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/latitude.ncks2 > $work/latitude
# log $? "lat extraction"

# join $work/longitude $work/latitude > $work/lonlat.xy
# awk  '{print $2"	"$3}' $work/lonlat.xy > $work/nodes.xy
# log $? "join node in a lonlat file"

## PLOT ##
gmt grdgradient $bathy $envelope -G$work/gradient.grd -A45 -Nt0.7 -V
log $? "grdgradient" 

gmt	grdimage $bathy $projection $envelope -C$palette -I$work/gradient.grd -P -K -V > ${outfile}.ps
log $? "grdimage"

gmt	grdcontour $bathy $envelope -S -J -C50 -A500+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
log $? "grdcontour"

gmt pscoast -V $projection $envelope -Df -G#d9bb7a -Cwhite -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

gmt psxy -V $work/nodes.xy -W0.1p -Sp0.03 $projection $envelope -P -K -O >> ${outfile}.ps
log $? "pscoast"

gmt	psbasemap $envelope $projection -Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Bathymetry(m) - Gulf of Lions ":WeSn -P -O -K >> ${outfile}.ps
log $? "psbasemap"

gmt	psscale -D21/6.5/13.5/0.3 -C$palette -B500:"":/:"": -E -O  >> ${outfile}.ps
log $? "psscale"

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"



