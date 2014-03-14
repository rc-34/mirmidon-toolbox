#!/bin/bash

#############################################################################################
# GLOBAL SCHEME OF THE SCRIPT                                                               #
#############################################################################################
#1 Get the sequence of year to compute
#1bis Verifiy the folder-tree and whether the mandatory files/exe are available
#2 For each year in that sequence -- sequentially work
	#2a prepare workdir with all mandatory files 
		#2a-1 particular case in strt pre-routine for year 1
		#2a-2 otherwise
	#2b replace changing path and date in inp files
	#2c submit pre-processing work
		#2c-1 particular case in strt pre-routine for year 1
		#2c-2 otherwise
	#2d submit shel.cmd
	#2e submit post-processing work
	#2f move outputs from working dir to corresponding outputs dir
#3 clean stuff
#############################################################################################

#RUN may be 'local' or 'hpclr'
export RUN="local"
export USER="chailanr"
export ROOTDIR="/Users/rchailan/Desktop/OnGoing/mirmidon-toolbox/SCRIPTS/megagol-autorun/work"
export outdirspec="/Users/rchailan/Desktop/OnGoing/mirmidon-toolbox/SCRIPTS/megagol-autorun/outputs/spec"
export outdirgridded="/Users/rchailan/Desktop/OnGoing/mirmidon-toolbox/SCRIPTS/megagol-autorun/outputs/gridded"
export INTERACTIVE=0

#output & error redirection to log
#exec 2>autorun.err 1>autorun.out

#source utilities
source ./resources/sh/utility.sh

rightnow
log "notice" "STARTING... $d"

#1
log "raw" "==== STEP1: Sequence of years to compute ===="
if [ $INTEREACTIVE -eq 0 ] 
	then
	beginningyear=2011
	endyear=2012
elif [ $# -ne 2 ]
then
	log "warning" "Usage: ./autorun.cmd BEGINNINGYEAR ENDYEAR"
	log "warning" "Exemple: ./autorun.cmd 1961 2012"
	log -1
else
	beginningyear=$1
	endyear=$2
fi
sequence=$(seq $beginningyear $endyear)
log $? "Sequence : determined."

#1bis
log "raw" "==== STEP1bis: Generic Inputs files availability ===="
source ./resources/sh/checkgenericinputs.sh
checkgenericinputs
log $? "Generic Inputs checked."

#2 for each year
log "raw" "==== STEP2: Computations ===="
for year in $sequence ; do
	rightnow
	log "raw" "==== $year - $d ===="
	#source format-inp and utilities
	source ./resources/sh/reformat.sh
	source ./resources/sh/checkinputs.sh
	source ./resources/sh/checkshelinputs.sh
	source ./resources/sh/cpfiles.sh

	isFirstyear=false
	workdir=$ROOTDIR/$year
	mkdir -p $ROOTDIR/$year
	cpexe $workdir
	log $? "Copy of exe"
	cpcmd $workdir
	log $? "Copy of generic cmd"
	cpinp $workdir
	log $? "Copy of generic inp"
	cpsh $workdir
	log $? "Copy sh files"
	cpmesh $workdir
	log $? "Copy mesh file"

	#2a workdir
	if [ $year -eq $beginningyear ] 
		#2a-1
		then
		isFirstyear=true
		#2b reformat
		formatinp $workdir $year $isFirstyear
		log $? "Inp files reformat"
		formatcmd $workdir
		log $? "Cmd files reformat"

		cparpera $workdir $year $isFirstyear
		log $? "Wind files copy"
		cpnm824 $workdir $year $isFirstyear
		log $? "Currents files copy"

		checkinputs $workdir
		log $? "Ready for submission"
		#2c-1
		llsubmit $workdir/pre-processing-firstyear.cmd
	else
		#2a-2
		#2b reformat
		formatinp $workdir $year $isFirstyear
		log $? "Inp files reformat"
		formatcmd $workdir
		log $? "Cmd files reformat"

		cparpera $workdir $year $isFirstyear
		log $? "Wind files copy"
		cpnm824 $workdir $year $isFirstyear
		log $? "Currents files copy"
		cprestart $workdir $year
		log $? "Restart files copy"

		checkinputs $workdir
		log $? "Ready for preprocessing submission"
		#2c-2
		llsubmit $workdir/pre-processing.cmd
	fi
	log $? "Pre-processing job"

	checkshelinputs $workdir
	log $? "Ready for shel submission"
	
	#2d shel submission
	llsubmit $workdir/shel.cmd
	log $? "Shel job"

	#threads for efficiency
	#2e post-processing
	#2d move outputs
	postprocess $workdir $year &
done

#3 clean
#rm -Rf work/*

#end
rightnow
echo "$d => That's all folks !!!"


function postprocess() {
	workdir=$1
	year=$2
	#2e post-processing
	llsubmit $workdir/post-processing.cmd
	log $? "Post-processing-$year"

	#2d move outputs
	mkdir $outdirspec/$year
	mkdir $outdirgridded/$year
	mv $workdir/OUNP*.nc $outdirspec/$year/.
	mv $workdir/MEDNORD*.nc $outdirgridded/$year/.
	log $? "move outputs - $year"
}
