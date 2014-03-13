#######################################################################################################
#											INFO													  #
#######################################################################################################
# Utilise le programme java pour convertir l'ensemble de la donnée transmise
# par Florence Sevault (ARPERA) dans un format compatible GMT.
#######################################################################################################

#!/bin/bash

if [ $# -ne 2 ] 
	then
	echo "Usage: ./javaarperafluxconverter.sh <path-to-arperaorig-flux-files> <path-to-arperacgmtcompliant-flux-files>"
	echo "example: ./javaarperafluxconverter.sh ./inputs/origin/ ./inputs/gmtcompliant/"
	exit 1
fi

## PARAMETERS ##
#outfile1=$(ls $1 |sed 's/.nc/.ps/')
origindir=$1
gmtcompliantdir=$2
variables="UX10 VY10 TCLS TSUR"
gridfile="grids/grids.nc"
jar="resources/mirmidon-io-netcdf-atmosflux-1.0-UNSTABLE.jar"
lon=medh.lon
lat=medh.lat
## END PARAMETERS ##

originfiles=$(ls $origindir)

# 1) foreach original file
for originfile in $originfiles; do

	# determine output file name
	gmtcompliantfile=ARPERACUR-${originfile:9:6}.nc

	# call java converter
	java -jar $jar $gmtcompliantdir/$gmtcompliantfile $gridfile $lon $lat $origindir/$originfile $variables
	
done ##end foreach original file


echo "...That's all folks!"
