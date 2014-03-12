#!/bin/bash


function formatinp(){
	WORKDIR=$1

	#format begin and end date
	beg=""$2"0101 000000"
	end=""$(( $2 + 1 ))"0101 000000"

	sed -i '' "s/((begindate))/$beg/g" $WORKDIR/*.inp
	sed -i '' "s/((enddate))/$end/g" $WORKDIR/*.inp

	restarttimestep="30240000"

	if [ ! $3 ]
		then
		#isnot first year
		begshel=""$(( $2 - 1 ))"1201 000000"
		sed -i '' "s/((begindate))/$begshel/g" $WORKDIR/ww3_shel.inp
		restarttimestep="32918400"
	fi
	
	#format restart timestep
	sed -i '' "s/((restarttimestep))/$restarttimestep/g" $WORKDIR/ww3_shel.inp

	return $?
}

function formatcmd(){
	WORKDIR=$1

	sed -i '' "s@pathtoworkingdir@$WORKDIR@g" $WORKDIR/*.cmd
	
	return $?
}