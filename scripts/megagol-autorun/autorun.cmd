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
	#2e scrutation while job isn't finished
	#2f move outputs from working dir to corresponding outputs dir
#3 clean stuff
#4 verify the overall behaviour of the script -- by checking availability of outputs files -- 
#############################################################################################

#RUN may be 'local' or 'hpclr'
export RUN="local"
export USER="chailanr"
export ROOTDIR="/Users/rchailan/Desktop/OnGoing/mirmidon-toolbox/SCRIPTS/megagol-autorun/work"

#output & error redirection to log
#exec 2>autorun.err 1>autorun.out

#source utilities
source ./resources/sh/utility.sh

rightnow
log "notice" "STARTING... $d"

#1
log "raw" "==== STEP1: Sequence of years to compute ===="
if [ $# -ne 2 ]
then
	log "warning" "Usage: ./autorun.cmd BEGINNINGYEAR ENDYEAR"
	log "warning" "Exemple: ./autorun.cmd 1961 2012"
	log -1
fi
beginningyear=$1
endyear=$2
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
	source ./resources/sh/cpfiles.sh

	isFirstyear=0
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
		isFirstyear=1
		formatinp $workdir $year $isFirstyear
		log $? "Inp files updates"
		formatcmd $workdir
		log $? "Cmd files updates"
		checkinputs $workdir
		log $? "Ready for submission"
		llsubmit $workdir/pre-processing-firstyear.cmd
	else
		#2a-2
		formatinp $workdir $year $isFirstyear
		log $? "Inp files updates"
		formatcmd $workdir
		log $? "Cmd files updates"
		checkinputs $workdir
		log $? "Ready for submission"
		llsubmit $workdir/pre-processing.cmd
	fi 
	log "raw" "==== STEP2a: workdir init ===="
done

#end
rightnow
echo "$d => That's all folks !!!"
