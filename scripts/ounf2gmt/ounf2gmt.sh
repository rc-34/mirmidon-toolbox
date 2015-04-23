#!/bin/bash

#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

## PARAMETERS ##
var=$1
layer=$2

if test "$#" -ne "2" ; then
	log -1 "should receive both the var and the layer to display."
fi

work="work"
bathy="inputs/sirocco.europe.grd"
flux="inputs/storm-0.nc"

outfile="outputs/GOLREG"
if [ -f $outfile ] ; then
	rm $outfile
fi

paletteshallowater="inputs/shallow-water.cpt"
paletteshs="inputs/hs.cpt"

projection=-JM20c
paramB="-Bf0.25a0.5:longitude:/f0.125a0.25:latitude:/:.'${var}':WeSn"
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
envelope="-R3/5/42.25/43.60" #envelope considered for fitmaxstab v1

## PROCESS GRID POINTS FROM WW3-4.18 ounf outputs ##
#lon 
ncks -v longitude $flux |awk '! /count/ {print $0}' |awk ' /degree_east/ {print $0}' |grep "node"  > $work/longitude.ncks
awk '{print $2}' $work/longitude.ncks > $work/longitude.ncks2
awk 'BEGIN { FS = "=" } ;{print $2}' $work/longitude.ncks2 > $work/longitude
log $? "long extraction"

#lat
ncks -v latitude $flux |awk '! /count/ {print $0}' |awk ' /degree_north/ {print $0}' |grep "node"  > $work/latitude.ncks
awk '{print $2}' $work/latitude.ncks > $work/latitude.ncks2
awk 'BEGIN { FS = "=" } ;{print $2}' $work/latitude.ncks2 > $work/latitude
log $? "lat extraction"

paste $work/longitude $work/latitude > $work/nodes.xy
log $? "join node in a lonlat file"

#process data 
# ncks -v $var -d time,$layer $flux |grep "time\[$layer\]" |grep "node" |awk 'BEGIN {FS="="} {print $3} ' |sed 's/ m//g' |sed 's/_/0.0/g' > $work/$var-$layer
ncks -v $var -d time,$layer $flux |awk '! /count/ {print $0}'| grep "time\[$layer\]" |grep "node" |awk 'BEGIN {FS="="} {print $4} ' |sed 's/ m//g' |sed 's/_/0.0/g' > $work/$var-$layer
log $? "extract $var-$layer in 1 column"

paste $work/nodes.xy $work/$var-$layer > $work/$var-$layer.xyz
log $? "prepare xyz file"

gmt nearneighbor $work/$var-$layer.xyz $envelope -S12k -N4/2 -I1k/1k -G$work/$var-$layer.grd
log $? "xyz2grd"

palette=$work/palette.cpt
# gmt grd2cpt -Z $work/$var-$layer.grd > $palette
gmt makecpt -Z -T0/20 -G0/20 -Cwysiwyg > $palette
log $? "gmt2cpt "

# ## PLOT ##
# gmt grdgradient $work/$var-$layer.grd $envelope -G$work/gradient.grd -A45 -Nt0.7
# log $? "grdgradient" 

# gmt	grdimage $work/$var-$layer.grd $projection $envelope -C$palette -I$work/gradient.grd -P -K  > ${outfile}.ps
# log $? "grdimage"

gmt	grdimage $work/$var-$layer.grd $projection $envelope -C$palette  -P -K  > ${outfile}.ps
log $? "grdimage"


gmt	grdcontour $work/$var-$layer.grd $envelope -S -J -C1 -A5+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
log $? "grdcontour"

gmt pscoast $projection $envelope -Df -G#d9bb7a -Cwhite -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

gmt	psbasemap $envelope $projection $paramB -P -K -O  >> ${outfile}.ps
log $? "psbasemap"

gmt	psscale -D21/6.5/13.5/0.3 -C$palette -B5:"":/:"": -E -O  >> ${outfile}.ps
log $? "psscale"

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"

rm ${outfile}.ps
log $? "clean"

