#######################################################################################################
#											INFO													  #
#######################################################################################################
# Boucle sur toutes les années
#
#
#
#######################################################################################################
#!/bin/bash

#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "STARTING... $d"


if [ $# -ne 0 ] 
	then
	log "warning" "Usage: ./anynemomed8orig2rec.sh"
	exit 1
fi

## PARAMETERS ##
gridfile="grids/grids.nc"
inputsdir="inputs"
origindir="origin"
concatdir="concat"
workdir="work"
outdir="outputs"
# years=$(seq 1961 1969)
years=$(seq 1995 2009)
sst="sst"
vomecrty="vomecrty"
vozocrtx="vozocrtx"
## END PARAMETERS ##

for year in  $years ; do
	# 0) clean & init
	log "notice" "STEP0: init"
	if [ -d $workdir ]
		then
		rm -Rf $workdir
	fi
	mkdir $workdir

	# 1) untar & move to the good folder
	log "notice" "STEP1: prepare origin"

	# create year directory
	mkdir -p $inputsdir/$concatdir/$year
	log "notice" "$year converstion"

	# select tar files
	sstuntardir=$( ls $inputsdir/$origindir/* | grep $sst | grep $year | grep \ 2 | sed 's/.\{1\}$//'  )
	log $? "list SST dir"
	vozocrtxuntardir=$( ls $inputsdir/$origindir/* | grep $vozocrtx | grep $year | grep \ 2 | sed 's/.\{1\}$//' )
	log $? "list VOZOCRTX dir"
	vomecrtyuntardir=$( ls $inputsdir/$origindir/* | grep $vomecrty | grep $year | grep \ 2 | sed 's/.\{1\}$//' )
	log $? "list VOMECRTY dir"

	log "notice" "STEP2: yearly concat"
	#outputs: each variable concatened by years in concat dir
	ncrcat -O "$sstuntardir"/*.nc $inputsdir/$concatdir/$year/$sst.nc
	log $? "ncrcat SST files"
	ncrcat -O "$vozocrtxuntardir"/*.nc $inputsdir/$concatdir/$year/$vozocrtx.nc
	log $? "ncrcat VOZOCRTX files"
	ncrcat -O "$vomecrtyuntardir"/*.nc $inputsdir/$concatdir/$year/$vomecrty.nc
	log $? "ncrcat VOMECRTY files"

	log "notice" "STEP3: regrid ncfiles for each variable"
	#outputs: each variable regrided by years in a temp dir
	mkdir $workdir/$year
	./nemomed8orig2rec.sh $inputsdir/$concatdir/$year $workdir/$year $year
	log $?

	log "notice" "STEP4: append each variable"
	#outputs: merge the three variables files into one to the outputs dir"
	outfile="NM824REC-"$year".nc"
	for ncfile in $workdir/$year/*.nc ; do
		mkdir -p $outdir/$year
		ncks -A $ncfile $outdir/$year/$outfile
		log $? "Append files to $outdir/$year/$outfile"
	done

done

log "notice" "STEP5 : clean"
log "notice" "debug : do not rm workdir"
# rm -Rf $workdir

log "notice" "...That's all folks!"
