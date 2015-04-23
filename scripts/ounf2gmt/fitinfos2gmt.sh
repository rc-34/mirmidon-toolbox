#!/bin/bash

#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

## PARAMETERS ##
var=$1

if test "$#" -ne "1" ; then
	log -1 "should receive the var to display."
fi

work="work"
bathy="inputs/sirocco.europe.grd"
flux="inputs/gpdfitsinfos.nc"
node="inputs/nodes.xy"

outfile="outputs/fitinfo-${var}"
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
#process data 
# ncks -v $var -d time,$layer $flux |grep "time\[$layer\]" |grep "node" |awk 'BEGIN {FS="="} {print $3} ' |sed 's/ m//g' |sed 's/_/0.0/g' > $work/$var-$layer
ncks -v $var  $flux |awk '! /count/ {print $0}' |grep "node\[" |awk 'BEGIN {FS="="} {print $3} ' > $work/$var
log $? "extract $var in 1 column"

paste $node $work/$var > $work/$var.xyz
log $? "prepare xyz file"

gmt nearneighbor $work/$var.xyz $envelope -S12k -N4/2 -I1k/1k -G$work/$var.grd
log $? "xyz2grd"

palette=$work/palette.cpt
# gmt grd2cpt -Z -G0/10 -T0/10 $work/$var.grd > $palette
case ${var} in
	sigma_s ) 
		gmt makecpt -Z  -T0/1 -G0/1 -Cjet > $palette ;;
	u_s ) 
		gmt makecpt -Z  -T0/5 -G0/5 -Cjet > $palette ;;
	gamma_s ) 
		gmt makecpt -Z  -T-0.5/0.8 -G-0.5/0.8 -Cjet > $palette ;;
	stderrgamma_s ) 
		gmt makecpt -Z  -T-0.5/0.5 -G-0.5/0.5 -Cjet > $palette ;;
	stderrsigma_s ) 
		gmt makecpt -Z  -T-0.5/0.5 -G-0.5/0.5 -Cjet > $palette ;;
esac
log $? "gmt2cpt "

## PLOT ##
gmt	grdimage $work/$var.grd $projection $envelope -C$palette  -P -K  > ${outfile}.ps
log $? "grdimage"

gmt	grdcontour $work/$var.grd $envelope -S -J -C1 -A5+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
log $? "grdcontour"

gmt pscoast $projection $envelope -Df -G#d9bb7a -C#d9bb7a -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

gmt	psbasemap $envelope $projection $paramB -P -K -O  >> ${outfile}.ps
log $? "psbasemap"

gmt	psscale -D21/9/17.5/0.3 -C$palette -B1:"":/:"": -E -O  >> ${outfile}.ps
log $? "psscale"

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"

rm ${outfile}.ps
log $? "clean"

