#! /bin/bash

#source utilities
source ./resources/sh/utility.sh


## PARAMETERS ##
projection=-JM20c
paramB=-Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Golfe du Lion ":WeSn
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

bathy="inputs/sirocco.europe.grd"
envelope="-R2.18/6.80/41.30/43.70" #envelope considered
envelope="-R3/5/42.25/43.60" #envelope considered
outfile="work/Selected-1level"
outfile="lhs"
work=work
palette="inputs/shallow-water.cpt"
png_resolution=600



# plot bathy from ww3
# bathy="work/bathyww3.grd"
# awk '{print $1"	"$2"	-"$3}' $work/nodes-envelope.xyz > $work/bathynode.xyz
# gmt xyz2grd $work/bathynode.xyz -G$bathy -I0.8k/0.8k $envelope 
# log $? "xyz2grd"
# gmt nearneighbor $work/bathynode.xyz -G$bathy -I0.8k/0.8k $envelope -S10k -N4/2
# log $? "xyz2grd"
# gmt grdgradient $bathy $envelope -G$work/gradient.grd -A45 -Nt0.7 -V
# log $? "grdgradient" 

#gmt	grdimage $bathy $projection $envelope -C$palette -I$work/gradient.grd -P -K -V > ${outfile}.ps
gmt	grdimage $bathy $projection $envelope -C$palette -P -K -V > ${outfile}.ps
log $? "grdimage"

gmt	grdcontour $bathy $envelope -S -J -C50 -A500+gwhite+f4 -Wcthinnest,black,solid -Wathinner,black,solid -P -O -K >> ${outfile}.ps
log $? "grdcontour"

gmt pscoast -V $projection $envelope -Df -G#d9bb7a -Cwhite -N1/0.2p,#0000FF,solid -P -K -O >> ${outfile}.ps
log $? "pscoast"

# plot close points
# gmt psxy -V $work/n.xyz -W0.1p -Sp0.03 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy"
# gmt psxy -V $work/pointlhs.xyz -W0.1p -Gred -Sp0.03 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy"


#plot all points layer per layer
# gmt psxy -V $work/nodes-0.xyz -W0.6p,red -Gred -S+0.1  $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-red"
# gmt psxy -V $work/nodes-1.xyz -W0.1p,blue -Gblue -S+0.06 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-blue"
# gmt psxy -V $work/nodes-2.xyz -W0.1p,orange -Gorange -Sa0.06 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-orange"
# gmt psxy -V $work/nodes-3.xyz -W0.1p,brown -Gbrown -Sd0.06 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-brown"
# gmt psxy -V $work/nodes-4.xyz -W0.1p,purple -purple -Si0.06 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-pink"

#plot lhs layer per layer
gmt psxy -V $work/lhs-0.xy -W0.6p,blue -Gblue -S+0.2 $projection $envelope -P -K -O >> ${outfile}.ps
log $? "psxy-red"
# gmt psxy -V $work/lhs-1.xy -W0.4p,blue -Gblue -S+0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-blue"
# gmt psxy -V $work/lhs-2.xy -W0.4p,orange -Gorange -Sa0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-orange"
# gmt psxy -V $work/lhs-3.xy -W0.4p,brown -Gbrown -Sd0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-brown"
# gmt psxy -V $work/lhs-4.xy -W0.8p,purple -Gpurple -Si0.12 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-pink"

# #plot sites-selected layer per layer
# gmt psxy -V $work/sites-0.xy -W0.6p,purple -Gpurple -S+0.2 $projection $envelope -P -K -O >> ${outfile}.ps
# gmt psxy -V $work/sites-v2.xyz -W0.6p,purple -Gpurple -S+0.2 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-red"
# gmt psxy -V $work/sites-1.xy -W0.4p,blue -Gblue -S+0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-blue"
# gmt psxy -V $work/sites-2.xy -W0.4p,orange -Gorange -Sa0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-orange"
# gmt psxy -V $work/sites-3.xy -W0.4p,brown -Gbrown -Sd0.10 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-brown"
# gmt psxy -V $work/sites-4.xy -W0.8p,purple -Gpurple -Si0.12 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-pink"

# gmt psxy -V outputs/sites.xy -W0.1p,red -Gred -Sp0.06 $projection $envelope -P -K -O >> ${outfile}.ps
# log $? "psxy-red"

gmt	psbasemap $envelope $projection -Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."100 Sites from Latin Hyper Cube Sampling ":WeSn -P -O  >> ${outfile}.ps
# gmt	psbasemap $envelope $projection -Bf0.5a1:longitude:/f0.25a0.5:latitude:/:."Computation Grid points ":WeSn -P -O -K >> ${outfile}.ps
log $? "psbasemap"

# gmt	psscale -D21/6.5/13.5/0.3 -C$palette -B500:"":/:"": -E -O  >> ${outfile}.ps
# log $? "psscale"

gmt ps2raster -E$png_resolution -A -Tg -P ${outfile}.ps
log $? "psraster"
