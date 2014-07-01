#######################################################################################################
#											INFO													  #
#######################################################################################################
# ww3 unstructured grid to regular for one netcdf file issued by the ww3_ounf(4.18) routine
#
# "Usage: ug2rec.sh [ncfile Path relative to inputs dir]"
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

## PARAMETERS ##
lat="latitude"
lon="longitude"
workdir="work"
indir="inputs"
outdir="outputs"
#variables="ucur vcur uwnd vwnd hs lm t01 fp dir hig uust vust cha utaw vtaw wch sxx syy sxy utwo vtwo bhd foc uuss vuss fp2s pp2s"
variables="hs "


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
## END PARAMETERS ##

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


## FOR ALL FILE IN INPUTSDIR --  IF INFILE RELATIVE TO INPUTS DIR NOT SPECIFIED --
files=$1
if [ $# -ne 1 ]
	then
	files=$(ls $indir)
fi
for file in $files; do
	rightnow
	log "notice" "Start conversion [$file] - $d"

	# timesteps collection
	timesteps=$( ncdump -v time $indir/$file | sed '1,330d' | awk '/[0-9],|[0-9] ;/ { print }' | awk ' {for (i=1; i<=NF; i++) {if ($i ~ /[0-9]/) {print $i}}}' | sed 's/,//g'  )
	log $? "Time steps collection"

	# long lat collection

	## FOR EACH VAR
	for var in $variables; do
		# index declaration for files merging
		i=0
		if [ ! -f $workdir/$file-$var-full.xyz ]; 
			then
			gmt grd2xyz $indir/$file?$var > $workdir/$file-$var-full.xyz
			log $? "Extraction $var in xyzfile"
		fi

				## FOR EACH TIME STEP
		for timestep in $timesteps; do
			index=$(printf "%04d" $i)
			
			echo $t
			awk '$2 == "$timestep" {print $1"	"$3}' $workdir/$file-$var-full.xyz > $workdir/$file-$var-$index.xyz
			#awk '$2 == "$timestep" {print $0}' $workdir/$file-$var-full.xyz > $workdir/$file-$var-$index.xyz
			i=$(( $i+1 ))


			# clean
			#rm $workdir/$file-$var-$index.xyz
		done 
		# clean
		#rm $workdir/$file-$var-full.xyz
	done
done 
rightnow
log "notice" "All files converted. - $d"
