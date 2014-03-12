#!/bin/bash

function checkgenericinputs(){
	returnCode=0

	## exe ##
	if [ ! -e recources/exe/ww3_grid ]
		then
		log "warning" "./recources/exe/ww3_grid does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e recources/exe/ww3_prnc ]
		then
		log "warning" "./recources/exe/ww3_prnc does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e recources/exe/ww3_strt ]
		then
		log "warning" "./recources/exe/ww3_strt does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e recources/exe/ww3_shel ]
		then
		log "warning" "./recources/exe/ww3_shel does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e recources/exe/ww3_ounf ]
		then
		log "warning" "./recources/exe/ww3_ounf does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e recources/exe/ww3_ounp ]
		then
		log "warning" "./recources/exe/ww3_ounp does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi

	## inp ##
	if [ ! -e recources/inp/ww3_grid.inp ]
		then
		log "warning" "./recources/inp/ww3_grid.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_prnc-current.inp ]
		then
		log "warning" "./recources/inp/ww3_prnc-current.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_prnc-wind.inp ]
		then
		log "warning" "./recources/inp/ww3_prnc-wind.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/sh/prnc.sh ]
		then
		log "warning" "./recources/sh/prnc.sh does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_strt.inp ]
		then
		log "warning" "./recources/inp/ww3_strt.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_shel.inp ]
		then
		log "warning" "./recources/inp/ww3_shel.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_outp.inp ]
		then
		log "warning" "./recources/inp/ww3_outp.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e recources/inp/ww3_ounp.inp ]
		then
		log "warning" "./recources/inp/ww3_ounp.inp does not exists."
		returnCode=-1
	fi

	return $returnCode
}