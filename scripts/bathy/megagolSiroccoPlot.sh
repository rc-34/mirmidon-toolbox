#!/bin/bash

## PARAMETERS ##
work="work"
bathy="sirocco.europe.grd"
outfile="GOLREG"
if [ -f $outfile ] ; then
	rm $outfile
fi


palette=/Users/rchailan/Applications/GMT-color-palette/bathy-ocean.cpt
palette=shallow-water.cpt
#gmt makecpt -Z-3000/0/25 -Csealand -G-3000/0 > shallow-water.cpt

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


gmt grdgradient $bathy $envelope -G$work/gradient.grd -A45 -Nt0.7 -V 
gmt	grdimage $bathy $projection $envelope -C$palette -I$work/gradient.grd -P -K -V > ${outfile}.ps
gmt	grdcontour $bathy $envelope -S -J -C50 -A500+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
gmt pscoast -V $projection $envelope -Df -G#d9bb7a -Cwhite -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
#gmt	psbasemap $envelope $projection $mapAnnotation -P -O -K >> ${outfile}.ps
gmt	psbasemap $envelope $projection -Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Bathymetry(m) - Gulf of Lions ":WeSn -P -O -K >> ${outfile}.ps

gmt	psscale -D21/6.5/13.5/0.3 -C$palette -B500:"":/:"": -E -O  >> ${outfile}.ps

#echo "5 9.5 12 0 5 BC " | pstext -R0/10/0/10 -J -Y0.8 -O -K >> ${outfile}.ps
#echo "5 9 12 0 5 BC Bathymetry (m)" | pstext -R -J -Y1.1 -O >> ${outfile}.ps

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps

#rm -f ${workingDir}/pal.cpt 
#rm -f ${outfile}.ps 




## BACKUP ##
#grd2xyz sirocco.europe.inv.grd -R-5.6/16.4/31.5/44.5 > megagol_sirocco_inv.xyz
#grd2xyz sirocco.europe.inv.grd -R-7/18/25/46 > megagol_sirocco_inv.xyz

# # basemap
# psbasemap $paramJ $envelope -Bf5a10:longitude:/f2.5a5:latitude:/:."Sirroco original Bathy ":WeSn -K -V >> $outfile1
# # add coast
# pscoast -V $paramJ $envelope -Dl -G#d9bb7a -Bf5a10:longitude:/f2.5a5:latitude:/:."Sirroco original Bathy ":WeSn -W1/0.2p,black,solid -N1/0.2p,#0000FF,solid -S#5BA0B8 -C0.1p,#5BA0B8,solid -K -O >> $outfile1 
# # add grid points
# psxy $bathy -JM20c $envelope -Sp0.01c -O -V >> $outfile1
