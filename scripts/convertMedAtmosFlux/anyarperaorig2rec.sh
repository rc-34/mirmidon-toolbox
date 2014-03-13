#######################################################################################################
#											INFO													  #
#######################################################################################################
# Ce script utilise le sous script "arperaorig2rec.sh" dans le but de reformatter l'ensemble de la
# donnée ARPERA (= 50 ans de données 1960/1 - 2012) dans des fichiers par année compatibles avec les
# les outils de pre/post processing netcdf conventionnels.
#######################################################################################################

#!/bin/bash

if [ $# -ne 1 ] 
	then
	echo "Usage: ./anyarperaorig2rec.sh <path-to-arperaorig-flux-files>"
	echo "example: ./anyarperaorig2rec.sh ./inputs/gmtcompliant"
	exit 1
fi

## PARAMETERS ##
#outfile1=$(ls $1 |sed 's/.nc/.ps/')
fluxesdir=$1
workdir="work"
outdir="outputs"

## END PARAMETERS ##

monthsfluxes=$(ls $fluxesdir)

# 1) foreach month
# convert monthly data to regular grid
for monthfluxes in $monthsfluxes; do
	echo "Preparing to work on $monthfluxes";

	#./arperaorig2rec.sh $1/$monthfluxes

done ## end foreach months

echo "Appending all months into yearly files"

# 2) foreach year
# append data in yearly files
#years=$(printf "%04d " $(seq 1960 2012))
years="2011 2012"
months=$(printf "%02d " $(seq 1 12))
#months="09 10 11 12"
isfirstyear=1
for year in $years; do
	outfile="ARPERAREC-$year.nc"
	infiles=""
	for month in $months; do
		infiles=$infiles"  $outdir/$year/$month/ARPERAREC-$year$month.nc"
	done

	if [ $isfirstyear -eq 0 ] 
		then 
		infiles="$outdir/$(($year-1))/12/ARPERAREC-$(($year-1))12.nc "$infiles
	fi
	isfirstyear=0

	echo "ncrcat $infiles $outdir/$year/$outfile..."
	ncrcat $infiles $outdir/$year/$outfile 
done

echo "...That's all folks!"