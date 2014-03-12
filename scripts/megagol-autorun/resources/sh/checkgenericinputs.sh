#!/bin/bash

function checkgenericinputs(){
	returnCode=0

	## exe ##
	if [ ! -e ./resources/exe/ww3_grid ]
		then
		log "warning" "./resources/exe/ww3_grid does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e resources/exe/ww3_prnc ]
		then
		log "warning" "./resources/exe/ww3_prnc does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e resources/exe/ww3_strt ]
		then
		log "warning" "./resources/exe/ww3_strt does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e resources/exe/ww3_shel ]
		then
		log "warning" "./resources/exe/ww3_shel does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e resources/exe/ww3_ounf ]
		then
		log "warning" "./resources/exe/ww3_ounf does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi
	if [ ! -e resources/exe/ww3_ounp ]
		then
		log "warning" "./resources/exe/ww3_ounp does not exists. Please verify ww3 compilation [and links]."
		returnCode=-1
	fi

	## inp ##
	if [ ! -e resources/inp/ww3_grid.inp ]
		then
		log "warning" "./resources/inp/ww3_grid.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_prnc-current.inp ]
		then
		log "warning" "./resources/inp/ww3_prnc-current.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_prnc-wind.inp ]
		then
		log "warning" "./resources/inp/ww3_prnc-wind.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/sh/prnc.sh ]
		then
		log "warning" "./resources/sh/prnc.sh does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_strt.inp ]
		then
		log "warning" "./resources/inp/ww3_strt.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_shel.inp ]
		then
		log "warning" "./resources/inp/ww3_shel.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_ounf.inp ]
		then
		log "warning" "./resources/inp/ww3_ounf.inp does not exists."
		returnCode=-1
	fi
	if [ ! -e resources/inp/ww3_ounp.inp ]
		then
		log "warning" "./resources/inp/ww3_ounp.inp does not exists."
		returnCode=-1
	fi

	return $returnCode
}