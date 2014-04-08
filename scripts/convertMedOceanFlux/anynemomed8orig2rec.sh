#######################################################################################################
#											INFO													  #
#######################################################################################################
# Boucle sur toutes les années
#
#
#
#######################################################################################################



#!/bin/bash

if [ $# -ne 0 ] 
	then
	echo "Usage: ./anynemomed8orig2rec.sh"
	exit 1
fi

## PARAMETERS ##
gridfile="grids/grids.nc"
variables="UX"
inputsdir="inputs"
origindir="origin"
concatdir="concat"
workdir="work"
outdir="outputs"
years=$(seq 1961 1969)
sst="sst"
vomecrty="vomecrty"
vozocrtx="vozocrtx"
## END PARAMETERS ##

# 0) clean & init
echo "STEP0: init"
if [ -d $workdir ]
	then
	rm -Rf $workdir
fi
mkdir $workdir

for year in  $years ; do
	# 1) untar & move to the good folder
	echo "STEP1: prepare origin"

	# create year directory
	mkdir -p $inputsdir/$concatdir/$year

	# select tar files
	sstuntardir=$( ls $inputsdir/$origindir/* | grep $sst | grep $year | grep \ 2 | sed 's/.\{1\}$//'  )
	vozocrtxuntardir=$( ls $inputsdir/$origindir/* | grep $vozocrtx | grep $year | grep \ 2 | sed 's/.\{1\}$//' )
	vomecrtyuntardir=$( ls $inputsdir/$origindir/* | grep $vomecrty | grep $year | grep \ 2 | sed 's/.\{1\}$//' )

	echo "STEP2: yearly concat"
	#outputs: each variable concatened by years in concat dir
	ncrcat "$sstuntardir"/*.nc $inputsdir/$concatdir/$year/$sst.nc
	ncrcat "$vozocrtxuntardir"/*.nc $inputsdir/$concatdir/$year/$vozocrtx.nc
	ncrcat "$vomecrtyuntardir"/*.nc $inputsdir/$concatdir/$year/$vomecrty.nc

	echo "STEP3: regrid ncfiles for each variable"
	#outputs: each variable regrided by years in a temp dir
	mkdir $workdir/$year
	./nemomed8orig2rec.sh $inputsdir/$concatdir/$year $workdir/$year $year

	echo "STEP4: append each variable"
	#outputs: merge the three variables files into one to the outputs dir"
	outfile="NM824REC-"$year".nc"
	for ncfile in $workdir/$year/*.nc ; do
		echo "ncks -A $ncfile $outfile..."
		mkdir -p $outdir/$year
		ncks -A $ncfile $outdir/$year/$outfile
	done

done

echo "STEP5 : clean"
rm -Rf $workdir

echo "...That's all folks!"
