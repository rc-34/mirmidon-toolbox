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