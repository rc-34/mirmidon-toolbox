#!/bin/bash

function checkshelinputs(){
	WORKINGDIR=$1
	returnCode=0

	## ww3 ##
	if [ ! -e $WORKINGDIR/wind.ww3 ]
		then
		log "warning" "$WORKINGDIR/wind.ww3 does not exists. Please verify pre-processing (prnc)."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/current.ww3 ]
		then
		log "warning" "$WORKINGDIR/wind.ww3 does not exists. Please verify pre-processing (prnc)."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/restart.ww3 ]
		then
		log "warning" "$WORKINGDIR/wind.ww3 does not exists. Please verify pre-processing (strt or copy)."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/mod_def.ww3 ]
		then
		log "warning" "$WORKINGDIR/mod_def.ww3 does not exists. Please verify pre-processing (grid)."
		returnCode=-1
	fi

	return $returnCode
}
