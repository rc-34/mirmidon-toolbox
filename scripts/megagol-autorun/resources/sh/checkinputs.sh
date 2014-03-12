#!/bin/bash

function checkinputs(){
	WORKINGDIR=$1
	returnCode=0

	## exe ##
	if [ ! -e $WORKINGDIR/ww3_grid ]
		then
		log "warning" "$WORKINGDIR/ww3_grid does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_prnc ]
		then
		log "warning" "$WORKINGDIR/ww3_prnc does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_strt ]
		then
		log "warning" "$WORKINGDIR/ww3_strt does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_shel ]
		then
		log "warning" "$WORKINGDIR/ww3_shel does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_ounf ]
		then
		log "warning" "$WORKINGDIR/ww3_ounf does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_ounp ]
		then
		log "warning" "$WORKINGDIR/ww3_ounp does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi

	## inp ##
	if [ ! -e $WORKINGDIR/ww3_grid.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_grid.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_prnc-current.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_prnc-current.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_prnc-wind.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_prnc-wind.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/prnc.sh ]
		then
		log "warning" "$WORKINGDIR/prnc.sh does not exists."
		returnCode=-1
	else
		chmod 775 $WORKINGDIR/prnc.sh
	fi
	if [ ! -e $WORKINGDIR/ww3_strt.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_strt.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_shel.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_shel.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_ounf.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_ounf.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e $WORKINGDIR/ww3_ounp.inp ]
		then
		log "warning" "$WORKINGDIR/ww3_ounp.inp does not exists."
		returnCode=-1
	fi

	if [ $(ls $WORKINGDIR | grep ARPERA*.nc | wc -l) -le 1 ]
		then
		log "warning" "No input wind matching ARPERA pattern found"
		returnCode=-1
	fi
	if [ $(ls $WORKINGDIR | grep NM824*.nc | wc -l) -le 1 ]
		then
		log "warning" "No input current matching NM824 pattern found"
		returnCode=-1
	fi

	return $returnCode
}
