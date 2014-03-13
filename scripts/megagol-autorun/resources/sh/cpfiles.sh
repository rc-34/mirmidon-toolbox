#!/bin/bash

function cpexe(){
	cp resources/exe/* $1/.
	return $?
}
function cpcmd(){
	cp resources/cmd/* $1/.
	return $?
}
function cpinp(){
	cp resources/inp/* $1/.
	return $?
}
function  cpmesh(){
	cp inputs/mesh/mesh.msh $1/.
	return $?
}
function  cpsh(){
	cp resources/sh/prnc.sh $1/.
	return $?
}
function cparpera(){
	year=$2
	WORKINGDIR=$1
	if [ $3 = false ]
		then
		#isnot first year
		yearm1=$(( $year - 1 ))
		#outputs: each variable concatened by years in concat dir
		ncrcat "inputs/wind/ARPERAREC-"$year".nc" "inputs/wind/ARPERAREC-"$yearm1".nc" $WORKINGDIR/"ARPERAREC-"$year".nc"
	else
		cp inputs/wind/ARPERAREC-$year.nc $1/.
	fi
	return $?
}
function cpnm824(){
	year=$2
	WORKINGDIR=$1
	if [ $3 = false ]
		then
		#isnot first year
		yearm1=$(( $year - 1 ))
		#outputs: each variable concatened by years in concat dir
		ncrcat "inputs/currents/NM824REC-"$year".nc" "inputs/currents/NM824REC-"$yearm1".nc" $WORKINGDIR/"NM824REC-"$year".nc"
	else
		cp inputs/currents/NM824REC-$year.nc $1/.
	fi
}
function cprestart(){
	year=$2
	WORKINGDIR=$1
	yearm1=$(( $year - 1 ))
	mv $WORKINGDIR/../$yearm1/restart001.ww3 $WORKINGDIR/restart.ww3
	
	return $?
}