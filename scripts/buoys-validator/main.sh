#!/bin/bash
export INTERACTIVE=0
export INDIR=$PWD/inputs
export MODEL=model
export SOLTC=soltc
export WORKDIR=work
export OUTDIR=outputs

# source utilities
source resources/sh/utility.sh
source resources/sh/preprocess-files.sh

if [ $INTERACTIVE -eq 0 ] 
	then
	infilenc="$INDIR/$MODEL/OUNP-MEDNORD-2011_tab.nc"
	beginningyear=20111001
	endyear=20111231
elif [ $# -ne 3 ]
then
	log "warning" "Usage: ./main.sh INFILE.NC BEGINNINGYEAR ENDYEAR"
	log "warning" "Exemple: ./main.sh INFILE.NC 1961 2012"
	log -1
else
	infilenc=$1
	beginningyear=$2
	endyear=$3
fi

if [ ! -f $infilenc ]
	then
	log "warning" "File not found : $infilenc"
	log -1
fi

# starting notification
rightnow
log "notice" "STARTING... $d"

# stations
stations="Espiguette Sete Leucate Banyuls MeteoFranc Magobs"
#stations="Espiguette Sete Leucate Banyuls"
#stations="Espiguette"


nctab2timevector $infilenc $WORKDIR/timevector.csv
log $? "Time-vector importation"

# timereformat $WORKDIR/timevector.csv
# log $? "Time-vector convertion to YYYY-MM-DD hh:mm:ss"

# foreach station
for station in $stations ; 
do 
log "notice" "Work on...$station"
case $station in
	"Espiguette")
	indexstation=1
		;;
	"Sete")
	indexstation=2
		;;
	"Leucate")
	indexstation=3
		;;
	"Banyuls")
	indexstation=4
		;;
	"MeteoFrance")
	indexstation=5
		;;
	"Magobs")
	indexstation=6
		;;
esac

nctab2hsvector $infilenc $station $WORKDIR/$station-hs-vector.csv
log $? "Hs-vector importation"

# join
echo "date	hs" > $WORKDIR/$station-hs-joined.csv
paste $WORKDIR/timevector.csv $WORKDIR/$station-hs-vector.csv | column -s '\t' -t >> $WORKDIR/$station-hs-joined.csv
sed "s/	/,/g" $WORKDIR/$station-hs-joined.csv > $OUTDIR/$station-hs.csv
log $? "$station-hs.csv edition"

# clean
rm  $WORKDIR/$station-hs-vector.csv $WORKDIR/$station-hs-joined.csv

done # end foreach station

rm $WORKDIR/timevector.csv