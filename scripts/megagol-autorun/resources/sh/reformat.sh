#!/bin/bash


function formatinp(){
	sed -i 's/path-to-working-dir/$1/g' *.inp

	if [ $3 ]
		then
		#is first year
		beg=""$2"0101 000000"
		end=""$(( $2 + 1 ))"0101 000000"
		sed -i "s/((beginyear))/$beg/g" *.inp
		sed -i "s/((endyear))/$end/g" *.inp
	else

	fi

	return $?
}

function formatcmd(){
	sed -i 's/path-to-working-dir/$1/g' *.cmd
	return $?
}