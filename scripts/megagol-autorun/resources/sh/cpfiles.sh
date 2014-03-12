#!/bin/bash

function cpexe(){
	cp exe/* $1
	return $?
}
function cpcmd(){
	cp cmd/* $1
	return $?
}
function cpinp(){
	cp inp/* $1
	return $?
}