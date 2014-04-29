#######################################################################################################
#											INFO													  #
#######################################################################################################
# ww3 unstructured grid to regular for one netcdf file issued by the ww3_ounf(4.18) routine
#
# Do not forget to specify
#
# 1- envelope
# 2- xinc and yinc
# 3- nearneighbor specifications (sectors/mandatory and radius)
#
# prereq. cdo & gmt 5 libraries in PATH
######################################################################################################

#!/bin/bash

if [ $# -ne 3 ] 
	then
	echo "Usage: ug2rec.sh [ncfile]"
	exit 1
fi

## PARAMETERS ##
lat="latitude"
lon="longitude"
workdir="work"
indir="inputs"
outdir="outputs"
variables="ucur vcur uwnd vwnd hs lm t01 fp dir hig uust vust cha utaw vtaw wch sxx syy sxy utwo vtwo bhd foc uuss vuss fp2s pp2s"
variable="hs "
## END PARAMETERS ##

# Interpolation parameters
# envelope = envelope
# Xinc = x axis increment
# Yinc = y axis increment
# paramN = nearneighbor sections/mandatory
# paramS = nearneighbor radius of circle (using Xinc)
envelope="-R-7/19/29/47"
Xinc=0.083
Yinc=0.083
paramN=-N10/2
paramS=-S1.5


#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

# create workdir
if [ ! -d $workdir ]
	then
	mkdir $workdir
fi
# create outdir
if [ ! -d $outdir ]
	then
	mkdir $outdir
fi
log $? "Directories availability."


## FOR ALL FILE IN INPUTSDIR --  IF INFILE NOT SPECIFIED --
files=$1
if [ $# -ne 1 ]
	then
	files=$(ls $inputs)
fi
for file in $file; do
	echo $file
	## FOR EACH VAR
		## FOR EACH TIME STEP

	rightnow
	log "notice" "$file converted at $d"
done 
log "notice" "All files converted."
