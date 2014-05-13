#!/bin/bash

## PARAMETERS ##
workdir=work
bathy="sirocco.europe.gmtcompliant.grd"
regbathygrd="regbathy.grd"
envelope="-R2.18/6.80/41.30/43.70"
#envelope="-R0.6/1/41/42"
xinc=0.015
yinx=0.015
soption="-S1k"
noption="-N4/1"


## BEGIN ##
rm -rf $workdir
if [ ! -d $workdir ] ; 
	then
	mkdir -p $workdir
fi

# convert to reg grid
gmt grd2xyz $bathy $envelope  -V > $workdir/golreg.xyz
gmt nearneighbor $workdir/golreg.xyz  -I$xinc/$yinc $soption $noption $envelope -V -G$workdir/$regbathygrd

# convert to ascii 
gmt grd2xyz $workdir/$regbathygrd $envelope -V > $workdir/golreg.xyz

# keep only z
if [ -f  $workdir/golreg.xyz ] ; 
	then
	awk '{ print $3 }' $workdir/golreg.xyz > $workdir/bathy_golreg_1col.txt
fi

# inverse bathy
gmt math $workdir/bathy_golreg_1col.txt NEG = $workdir/bathy_golreg_1col_inv.txt
# 0.00 for positive value (means not a sea point)
awk '{ if ($1 ~ /-.*/ ) print "0.00";  else print $1; }' $workdir/bathy_golreg_1col_inv.txt > bathy_golreg.txt
#write on 20 columns


#grd2xyz sirocco.europe.inv.grd -R-5.6/16.4/31.5/44.5 > megagol_sirocco_inv.xyz
#grd2xyz sirocco.europe.inv.grd -R-7/18/25/46 > megagol_sirocco_inv.xyz


##backup##
#extract long/lat
#grd2xyz -V ${gridfile}?medh.lon > longitude
#grd2xyz -V ${gridfile}?medh.lat > latitude 
#grd2xyz -V ${fluxfile}?TSUR > flux

#join longitude latitude > temp
#join temp flux > joined.xyz
#awk '{ print  $3" "$5" "$7}' joined.xyz > grid.xyz