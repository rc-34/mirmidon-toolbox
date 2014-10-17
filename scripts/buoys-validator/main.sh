#!/bin/bash
export INTERACTIVE=0
export INDIR=$PWD/inputs
export MODEL=model
export SOLTC=soltc
export WORKDIR=work
export OUTDIR=outputs
export ARPERADIR=$INDIR/arpera/origin
export ARPERAREGINTDIR=$INDIR/arpera/regint

# source utilities
source resources/sh/utility.sh
source resources/sh/preprocess-files.sh

if [ $INTERACTIVE -eq 0 ] 
	then
	#infilenc="$INDIR/$MODEL/OUNP-MEDNORD-2010_tab2.nc"
    # infilenc="$INDIR/$MODEL/OUNP-MEDNORD-2002_tab.nc"
    # infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab2.nc"
    #infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab-mar.nc"
    #infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab-allyear.nc"
    infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab_quad.nc"
    infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab-10m-quad.nc"
    infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab-10m-quad-wns.nc"
    infilenc="$INDIR/$MODEL/OUNP-LSF-MEDNORD-2012_tab-25k-quad.nc"
    infilerec="$ARPERAREGINTDIR/ARPERAREC-2012.nc"
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
stations="MeteoFranc"

# nctab2timevectorcdo $infilenc $WORKDIR/timevector.csv
log $? "Time-vector importation"

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
	"MeteoFranc")
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

# # HS
# # echo "Station "$station","$indexstation
# nctab2hsvector $infilenc $station $WORKDIR/$station-hs-vector.csv
# log $? "Hs-vector importation"
# # join
# echo "date	hs" > $WORKDIR/$station-hs-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-hs-vector.csv | column -s '\t' -t >> $WORKDIR/$station-hs-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-hs-joined.csv > $OUTDIR/$station-hs.csv
# log $? "$station-hs.csv edition"
# # clean
# rm $WORKDIR/$station-hs-vector.csv $WORKDIR/$station-hs-joined.csv

# # Dir
# nctab2hsdirvector $infilenc $station $WORKDIR/$station-dir-vector.csv
# log $? "dir-vector importation"
# # join
# echo "date	th1m" > $WORKDIR/$station-dir-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-dir-vector.csv | column -s '\t' -t >> $WORKDIR/$station-dir-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-dir-joined.csv > $OUTDIR/$station-dir.csv
# log $? "$station-dir.csv edition"
# # clean
# rm  $WORKDIR/$station-dir-vector.csv $WORKDIR/$station-dir-joined.csv

# # PeakcDir
# nctab2hsdirpeakvector $infilenc $station $WORKDIR/$station-dirpeak-vector.csv
# log $? "dirpeak-vector importation"
# # join
# echo "date	th1p" > $WORKDIR/$station-dirpeak-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-dirpeak-vector.csv | column -s '\t' -t >> $WORKDIR/$station-dirpeak-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-dirpeak-joined.csv > $OUTDIR/$station-dirpeak.csv
# log $? "$station-dirpeak.csv edition"
# # clean
# rm  $WORKDIR/$station-dirpeak-vector.csv $WORKDIR/$station-dirpeak-joined.csv

# # FpPeak
# nctab2fpvector $infilenc $station $WORKDIR/$station-fp-vector.csv
# log $? "frequencepeak-vector importation"
# # join
# echo "date	fp" > $WORKDIR/$station-fp-joined.csv
# paste $WORKDIR/timevector.csv $WORKDIR/$station-fp-vector.csv | column -s '\t' -t >> $WORKDIR/$station-fp-joined.csv
# sed "s/	/,/g" $WORKDIR/$station-fp-joined.csv > $OUTDIR/$station-fp.csv
# log $? "$station-fp.csv edition"
# # clean
# rm  $WORKDIR/$station-fp-vector.csv $WORKDIR/$station-fp-joined.csv

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

if [ $indexstation -eq 5 ] 
	then
	# WND MODEL WW3
	nctab2wndvector $infilenc $station $WORKDIR/$station-wnd-vector.csv
	log $? "Wind-vector importation"
	# join
	echo "date	wnd" > $WORKDIR/$station-wnd-joined.csv
	paste $WORKDIR/timevector.csv $WORKDIR/$station-wnd-vector.csv | column -s '\t' -t >> $WORKDIR/$station-wnd-joined.csv
	sed "s/	/,/g" $WORKDIR/$station-wnd-joined.csv > $OUTDIR/$station-wnd.csv
	log $? "$station-wnd.csv edition"
	# clean

	# # WND ARPERA
	# for node in 673 674 675 772 771 770 ; do
	# 	rm  $WORKDIR/arpera-wnd-vector-U.csv $WORKDIR/arpera-wnd-vector-V.csv
	# 	for arperaorigin in $(ls $ARPERADIR) ; do
	# 		#extraction of the closest points
	# 		ncks -v UX10 -d nbr_pts,$node,$node $ARPERADIR/$arperaorigin  | sed '1,8d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $3}' | sed '/^$/d' |sed '$d' >> $WORKDIR/arpera-wnd-vector-U.csv
	# 		ncks -v VY10 -d nbr_pts,$node,$node $ARPERADIR/$arperaorigin  | sed '1,8d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $3}' | sed '/^$/d' |sed '$d' >> $WORKDIR/arpera-wnd-vector-V.csv
	# 	done
	# 	paste $WORKDIR/arpera-wnd-vector-U.csv $WORKDIR/arpera-wnd-vector-V.csv | column -s '\t' -t > $WORKDIR/arpera-wnd-vector.csv
		
	# 	Rscript resources/r/norm.R $WORKDIR/arpera-wnd-vector.csv $WORKDIR/arpera-wnd-norm.csv
	# 	lengtharpera=$(wc -l $WORKDIR/arpera-wnd-norm.csv)

	# 	Rscript resources/r/date-sequence.R "2012-01-01 18:00:00" $lengtharpera $WORKDIR/timevector-arpera.csv
	# 	echo "date	wnd-arpera" > $WORKDIR/arpera-wnd-joined.csv
	# 	paste $WORKDIR/timevector-arpera.csv  $WORKDIR/arpera-wnd-norm.csv | column -s '\t' -t >> $WORKDIR/arpera-wnd-joined.csv
	# 	sed "s/	/,/g" $WORKDIR/arpera-wnd-joined.csv > $OUTDIR/arpera-wnd-$node.csv
	# 	log $? "arpera-wnd-$node.csv edition"
	# 	# clean
	# 	rm  $WORKDIR/arpera-wnd-vector.csv $WORKDIR/arpera-wnd-joined.csv $WORKDIR/arpera-wnd-norm.csv
	# done 

	# # WND REGINT-ARPERA
	# echo "4.64 42.06" > $WORKDIR/LION.xy
	# totalframe=$(wc -l $WORKDIR/timevector-arpera.csv |sed 's/[^0-9]*//g')
	# rm $WORKDIR/U-ARPERAREC.csv $WORKDIR/V-ARPERAREC.csv
	# for frame in $(seq 1 $totalframe); do
	# 	N=$(($frame - 1))
	# 	GU="-G$infilerec?UX10[$N]"
	# 	GV="-G$infilerec?VY10[$N]"
	# 	gmt grdtrack $WORKDIR/LION.xy $GU -nl -Z $envelope >> $WORKDIR/U-ARPERAREC.csv 
	# 	gmt grdtrack $WORKDIR/LION.xy $GV -nl -Z $envelope >> $WORKDIR/V-ARPERAREC.csv 
	# done
	# paste $WORKDIR/U-ARPERAREC.csv $WORKDIR/V-ARPERAREC.csv | column -s '\t' -t > $WORKDIR/arperarec-wnd-vector.csv
	
	# Rscript resources/r/norm.R $WORKDIR/arperarec-wnd-vector.csv $WORKDIR/arperarec-wnd-norm.csv

	# echo "date	wnd-arperarec" > $WORKDIR/arperarec-wnd-joined.csv
	# paste $WORKDIR/timevector-arpera.csv  $WORKDIR/arperarec-wnd-norm.csv | column -s '\t' -t >> $WORKDIR/arperarec-wnd-joined.csv
	# sed "s/	/,/g" $WORKDIR/arperarec-wnd-joined.csv > $OUTDIR/arperarec-wnd.csv
	# log $? "arperarec-wnd.csv edition"
	# # clean
	# rm  $WORKDIR/arperarec-wnd-vector.csv $WORKDIR/arperarec-wnd-joined.csv $WORKDIR/arperarec-wnd-norm.csv $WORKDIR/timevector-arpera.csv
fi

done # end foreach station
#rm $WORKDIR/timevector.csv