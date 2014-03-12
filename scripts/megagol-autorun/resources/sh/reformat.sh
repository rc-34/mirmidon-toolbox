#!/bin/bash


function formatinp(){
	#format begin and end date
	beg=""$2"0101 000000"
	end=""$(( $2 + 1 ))"0101 000000"
	sed -i "s/((begindate))/$beg/g" *.inp
	sed -i "s/((enddate))/$end/g" *.inp

	restarttimestep="30240000"

	if [ ! $3 ]
		then
		#isnot first year
		begshel=""$(( $2 - 1 ))"1201 000000"
		sed -i "s/((begindate))/$begshel/g" ww3_shel.inp
		restarttimestep="32918400"
	fi
	
	#format restart timestep
	sed -i "s/((restarttimestep))/$restarttimestep/g" ww3_shel.inp

	return $?
}

function formatcmd(){
	sed -i 's/path-to-working-dir/$1/g' *.cmd
	return $?
}