#!/bin/bash

function formatinp(){
	WORKDIR=$1
	year=$2

	#format begin and end date
	beg=""$year"0101 000000"
	end=""$(( $year + 1 ))"0101 000000"

	sed -i  "s/((begindate))/$beg/g" $WORKDIR/*.inp
	sed -i  "s/((enddate))/$end/g" $WORKDIR/*.inp

	restarttimestep="30240000"
	
	if [ $3 = false ]
		then
		#isnot first year
		begshel=""$(( $year - 1 ))"1217 000000"
		sed -i  "s/$beg/$begshel/g" $WORKDIR/ww3_shel.inp

		restarttimestep="31536000"
	fi
	
	isLeapYear $year
	if [ $? = 1 ]
		then
		log "warning" "I am a leap year - specific restart timestep"
		restarttimestep=$(( $restarttimestep + 86400))
	fi
	#format restart timestep
	sed -i  "s/((restarttimestep))/$restarttimestep/g" $WORKDIR/ww3_shel.inp


	#change path of nc file to import in prnc.inp files
	sed -i  "s/((year))/$year/g" $WORKDIR/*.inp

	return $?
}

function formatcmd(){
	WORKDIR=$1

	sed -i  "s@pathtoworkingdir@$WORKDIR@g" $WORKDIR/*.cmd
	
	return $?
}

function isLeapYear (){
 # if ((year modulo 4 is 0) and (year modulo 100 is not 0))
 #    or (year modulo 400 is 0)
 #        then true
 #    else false
 year=$1
 if [[ ( $(( $year % 4 )) = 0 ) && ( $(( $year % 100 )) != 0 ) || ( $(( $year % 400 )) = 0 ) ]] ;
 	then
 	return 1
 else 
 	return 0
 fi

}
    