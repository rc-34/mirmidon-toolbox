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
flux="inputs/20150423-1siteref-1972/storm-2.nc"
flux="inputs/20150423-hyperslab-3z/storm-1.nc"
# flux="inputs/storm-0-bis.nc"

outfile="outputs/storm-${var}-${layer}"
if [ -f $outfile ] ; then
	rm $outfile
fi

paletteshallowater="inputs/shallow-water.cpt"
paletteshs="inputs/hs.cpt"

projection=-JM20c
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

min=0
ncwa -4 -O -b -y max -v $var $flux $work/foo.nc
log $? "ncwa find max"

max=$(ncks -v $var $work/foo.nc | grep "${var}\[" | awk 'BEGIN {FS="="} {print $4}' | awk '{print $1}')
log $? "extract max"

if [ "$( printf "%.0f" $max )" -ge 15 ]
	then
	max=15
fi


palette=$work/palette.cpt
# gmt grd2cpt -Z -T0  > $palette
gmt makecpt -Z -T${min}/${max} -G${min}/${max} -Cjet > $palette
log $? "gmt2cpt "

# process direction
ncks -v dir $flux -a -d time,$layer |awk '! /count/ {print $0}'| grep "time\[$layer\]" |grep "node" |awk 'BEGIN {FS="="} {print $4} ' |awk '{print $1}' > $work/dir
log $? "ncks dir extraction"

paste $work/nodes.xy  $work/dir > $work/fielddir
sed 's/_/NaN/g' $work/fielddir > $work/fielddir2
sed 's/degree//g' $work/fielddir2 > $work/fielddir.xyz
log $? "paste dir and lonlat file"

awk '{if ($3 != NaN) { dir=($3+180) % 360;print $1" "$2" "dir " 3"}}' $work/fielddir.xyz > $work/dir.xyz
log $? "dir convertion"

date=$(cdo showtimestamp inputs/20150423-1siteref-1972/storm-2.nc  2> /dev/null | awk '{print $3}' | sed 's/T/ /'g | sed 's/:/H/g' | sed 's/...$//')

paramB="-Bf0.25a0.5:longitude:/f0.125a0.25:latitude:/:.'${var}':WeSn"

# ## PLOT ##
# gmt grdgradient $work/$var-$layer.grd $envelope -G$work/gradient.grd -A45 -Nt0.7
# log $? "grdgradient" 

# gmt	grdimage $work/$var-$layer.grd $projection $envelope -C$palette -I$work/gradient.grd -P -K  > ${outfile}.ps
# log $? "grdimage"

gmt	grdimage $work/$var-$layer.grd $projection $envelope -C$palette  -P -K  > ${outfile}.ps
log $? "grdimage"

gmt	psxy $work/dir.xyz -S=3p+e -W0.2p $projection $envelope -P -K -O >> ${outfile}.ps
log $? "psxy direction"

gmt	grdcontour $work/$var-$layer.grd $envelope -S -J -C1 -A5+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
log $? "grdcontour"

gmt pscoast $projection $envelope -Df -G#d9bb7a -C#d9bb7a -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

title="[$layer]     ${var}      (${date})"
gmt	psbasemap $envelope $projection  -Bf0.25a0.5:longitude:/f0.125a0.25:latitude:/:."$title":WeSn -P -K -O  >> ${outfile}.ps
log $? "psbasemap"

gmt	psscale -D21/9/17.5/0.3 -C$palette -B1:"":/:"": -E -O  >> ${outfile}.ps
log $? "psscale"

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"

rm ${outfile}.ps
log $? "clean"

