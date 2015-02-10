#!/bin/bash

## PARAMETERS ##
gridfile="grids.nc"
fluxfile="FLUX_EG4_201201.nc"
fluxfilerec="ARPERAREC-2012.nc"
workdir="work"
outfile1="arperaGrid"
rm $outfile1

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."Arpera original Grid (zoom)":WeSn

#png_resolution=800
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
envelope="-R-20/50/28/53"
envelope="-R2/6.80/41.30/43.70"
# envelope="-R1/10/40/48"

#extract long/lat
ncks -v medh.lon ${gridfile}  | sed '1,5d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $2}' > $workdir/longitude
ncks -v medh.lat ${gridfile}  | sed '1,5d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $2}' > $workdir/latitude

paste $workdir/longitude $workdir/latitude > $workdir/temp
cat -n $workdir/temp > $workdir/temp2
awk '{b=($1-1);print  $2" "$3" "b}' $workdir/temp2 > $workdir/grid.xyz

# basemap
gmt psbasemap $paramJ $envelope -Bf0.5a1:longitude:/f.5a1:latitude:/:."Arpera & ArperaREC Grid (zoom)":WeSn -P -K -V >> ${outfile1}.ps

# add coast
gmt pscoast $paramJ $envelope -Df -G200 -C200 -K -P -O >> ${outfile1}.ps

# add buoy LION location
echo "4.64 42.06 LION"> $workdir/buoy.xy
gmt psxy $workdir/buoy.xy $paramJ $envelope -Sd0.3c -Gblue -Wblue -K -O -P -V >> ${outfile1}.ps
gmt pstext $workdir/buoy.xy -JM20c $envelope -D0.5k -O -K -P -V >> ${outfile1}.ps

# add grid ARPERAREC points
gmt grd2xyz $fluxfilerec?TSUR[1] $envelope  > $workdir/gridrec.xyz
gmt psxy $workdir/gridrec.xyz $paramJ $envelope -Sp0.1c -Gpurple -Wpurple -K -O -P -V >> ${outfile1}.ps
# gmt pstext gridrec.xyz -JM20c $envelope -O -P -V >> ${outfile1}.ps

# add grid ARPERA points
gmt psxy $workdir/grid.xyz $paramJ $envelope -Sp0.1c -Wgreen -Ggreen  -O -P -V >> ${outfile1}.ps
# gmt pstext $workdir/grid.xyz $paramJ $envelope -O -P -V >> ${outfile1}.ps

# To raster
#gmt ps2raster -Tg -E600 -P -A -D. ${outfile1}.ps
gmt ps2raster -Tg -P -A -D. ${outfile1}.ps

# Clean folder
rm -f ${outfile1}.ps