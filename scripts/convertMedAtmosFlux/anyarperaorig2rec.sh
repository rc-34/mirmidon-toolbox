#!/bin/bash
#######################################################################################################
#											INFO													  #
#######################################################################################################
# Ce script utilise le sous script "arperaorig2rec.sh" dans le but de reformatter l'ensemble de la
# donnée ARPERA (= 50 ans de données 1960/1 - 2012) dans des fichiers par année compatibles avec les
# les outils de pre/post processing netcdf conventionnels.
#######################################################################################################
#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"

if [ $# -ne 1 ] 
	then
	echo "Usage: ./anyarperaorig2rec.sh <path-to-arperaorig-flux-files>"
	echo "example: ./anyarperaorig2rec.sh ./inputs/gmtcompliant"
	exit 1
fi

## PARAMETERS ##
fluxesdir=$1
workdir="work"
outdir="outputs"
## END PARAMETERS ##

monthsfluxes=$(ls $fluxesdir)
log "notice" "$monthsfluxes"

# 1) foreach month
# convert monthly data to regular grid
for monthfluxes in $monthsfluxes; do
	log "notice" "Preparing to work on $monthfluxes";
	./arperaorig2rec.sh $1/$monthfluxes
done ## end foreach months

log "notice" "Appending all months into yearly files"

# 2) foreach year
# append data in yearly files
years=$(printf "%04d " $(seq 1959 2012))
# years="2012 2012"
months=$(printf "%02d " $(seq 1 12))
# months="09"
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

	# log "notice" "ncrcat $infiles $outdir/$year/$outfile..."
	/Users/rchailan/Applications/nco/4.4.6/bin/ncrcat $infiles $outdir/$year/$outfile 
	log $? "ncrcat $year"

	rm -Rf $workdir/*
	log $? "Clean "
done
echo "...That's all folks!"