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
	 infilenc="$INDIR/$MODEL/OUNP-MEDNORD-2010_tab2.nc"
	#infilenc="$INDIR/$MODEL/OUNP-MEDNORD-2001_tab.nc"
	beginningyear=20110101
	endyear=20121231
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
stations="Espiguette Sete Leucate Banyuls MeteoFranc Magobs TOULON MARSEILLE CAMARGUE"
#stations="Espiguette Sete Leucate Banyuls"
#stations="Espiguette"


nctab2timevectorcdo $infilenc $WORKDIR/timevector.csv
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
	"TOULON")
	indexstation=10
		;;
	"MARSEILLE")
	indexstation=11
		;;
	"CAMARGUE")
	indexstation=28
		;;	
esac

# HS
nctab2hsvector $infilenc $station $WORKDIR/$station-hs-vector.csv
log $? "Hs-vector importation"
# join
echo "date	hs" > $WORKDIR/$station-hs-joined.csv
paste $WORKDIR/timevector.csv $WORKDIR/$station-hs-vector.csv | column -s '\t' -t >> $WORKDIR/$station-hs-joined.csv
sed "s/	/,/g" $WORKDIR/$station-hs-joined.csv > $OUTDIR/$station-hs.csv
log $? "$station-hs.csv edition"
# clean
rm  $WORKDIR/$station-hs-vector.csv $WORKDIR/$station-hs-joined.csv


# Dir
nctab2hsdirvector $infilenc $station $WORKDIR/$station-dir-vector.csv
log $? "dir-vector importation"
# join
echo "date	th1m" > $WORKDIR/$station-dir-joined.csv
paste $WORKDIR/timevector.csv $WORKDIR/$station-dir-vector.csv | column -s '\t' -t >> $WORKDIR/$station-dir-joined.csv
sed "s/	/,/g" $WORKDIR/$station-dir-joined.csv > $OUTDIR/$station-dir.csv
log $? "$station-dir.csv edition"
# clean
rm  $WORKDIR/$station-dir-vector.csv $WORKDIR/$station-dir-joined.csv


# PeakcDir
nctab2hsdirpeakvector $infilenc $station $WORKDIR/$station-dirpeak-vector.csv
log $? "dirpeak-vector importation"
# join
echo "date	th1p" > $WORKDIR/$station-dirpeak-joined.csv
paste $WORKDIR/timevector.csv $WORKDIR/$station-dirpeak-vector.csv | column -s '\t' -t >> $WORKDIR/$station-dirpeak-joined.csv
sed "s/	/,/g" $WORKDIR/$station-dirpeak-joined.csv > $OUTDIR/$station-dirpeak.csv
log $? "$station-dirpeak.csv edition"
# clean
rm  $WORKDIR/$station-dirpeak-vector.csv $WORKDIR/$station-dirpeak-joined.csv


# FpPeak
nctab2fpvector $infilenc $station $WORKDIR/$station-fp-vector.csv
log $? "frequencepeak-vector importation"
# join
echo "date	fp" > $WORKDIR/$station-fp-joined.csv
paste $WORKDIR/timevector.csv $WORKDIR/$station-fp-vector.csv | column -s '\t' -t >> $WORKDIR/$station-fp-joined.csv
sed "s/	/,/g" $WORKDIR/$station-fp-joined.csv > $OUTDIR/$station-fp.csv
log $? "$station-fp.csv edition"
# clean
rm  $WORKDIR/$station-fp-vector.csv $WORKDIR/$station-fp-joined.csv



# # WND
# nctab2wndvector $infilenc $station $WORKDIR/$station-wnd-vector.csv
# log $? "Wind-vector importation"
# # join
# echo "date	wnd" > $WORKDIR/$station-wnd-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-wnd-vector.csv | column -s '\t' -t >> $WORKDIR/$station-wnd-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-wnd-joined.csv > $OUTDIR/$station-wnd.csv
# log $? "$station-wnd.csv edition"
# # clean
# rm  $WORKDIR/$station-wnd-vector.csv $WORKDIR/$station-wnd-joined.csv

# # WNDDIR
# nctab2wnddirvector $infilenc $station $WORKDIR/$station-wnddir-vector.csv
# log $? "Winddir-vector importation"
# # join
# echo "date	wnddir" > $WORKDIR/$station-wnddir-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-wnddir-vector.csv | column -s '\t' -t >> $WORKDIR/$station-wnddir-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-wnddir-joined.csv > $OUTDIR/$station-wnddir.csv
# log $? "$station-wnd.csv edition"
# # clean
# rm  $WORKDIR/$station-wnddir-vector.csv $WORKDIR/$station-wnddir-joined.csv


done # end foreach station

#rm $WORKDIR/timevector.csv