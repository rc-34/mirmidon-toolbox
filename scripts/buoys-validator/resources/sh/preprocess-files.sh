#!/bin/bash

function nctab2timevector(){

	if [ $# -ne 2 ] 
		then
		log "warning" "bad use of nctab2timevector function - missing or too much parameters"
		return 1
	fi
	infilenc=$1
	outfile=$2

	# retrieve column vector of time
	ncks -s "%f\n" -C -h -d station,1 -v time $infilenc | tail -n +11 | sed '$d' | sed '$d' > t.tmp

	# dimension number of Time - for verification
	nbtotal=$( ncdump -h $infilenc | grep time | head -1 | sed 's/[^0-9]//g' )

	if [ $( wc -l t.tmp | sed 's/[^0-9]//g' ) -ne $nbtotal ] 
		then
		log "warning" "issue while comparing initial time dimension with the created vector file"
		return 1
	fi


	# retrieve date origin for reformat
	# dateorg=$( ncks -s "%f\n" -C -h -d station,1 -v time $infilenc | grep "days since" | awk '{print $NF}' )
	# origin=$(date -j  -f '%Y-%m-%dT%H:%M:%SZ' "$dateorg" +'%Y-%m-%d %H:%M:%S')

	# d=$( Rscript resources/r/add-julian.R $(head -1 t.tmp) | awk '{print $2}')

	# dd=$(date -d "$origin $d years" +'%Y-%m-%d %H:%M:%S')
	dateorg="2011-01-01T00:00:00Z"
	origin=$(date -j  -f '%Y-%m-%dT%H:%M:%SZ' "$dateorg" +'%Y-%m-%d %H:%M:%S')

	# create sequence of date to avoid manipulating julian days
	Rscript resources/r/date-sequence.R "$origin" $nbtotal tmp2.csv
	sed '1d' tmp2.csv > $outfile 

	# clean
	rm t.tmp tmp2.csv

}


function nctab2hsvector(){
	if [ $# -ne 3 ] 
		then
		log "warning" "bad use of nctab2hsvector function - missing or too much parameters"
		return 1
	fi
	infilenc=$1
	outfile=$3
	station=$2

	# retrieve column vector hs  from ounp-tab.nc file
	ncks -s "%f\n" -C -h -d station,$indexstation -v hs $infilenc | tail -n+14 | sed '$d' | sed '$d' > $outfile

	# dimension number of Time - for verification
	nbtotal=$( ncdump -h $infilenc | grep time | head -1 | sed 's/[^0-9]//g' )
	if [ $( wc -l $outfile | sed 's/[^0-9]//g' ) -ne $nbtotal ] 
		then
		log "warning" "issue while comparing initial time dimension with the created vector file"
		return 1
	fi
}

function nctab2wndvector(){
	if [ $# -ne 3 ] 
		then
		log "warning" "bad use of nctab2wndvector function - missing or too much parameters"
		return 1
	fi
	infilenc=$1
	outfile=$3
	station=$2

	# retrieve column vector wnd  from ounp-tab.nc file
	ncks -s "%f\n" -C -h -d station,$indexstation -v wnd $infilenc | tail -n+14 | sed '$d' | sed '$d' > $outfile

	# dimension number of Time - for verification
	nbtotal=$( ncdump -h $infilenc | grep time | head -1 | sed 's/[^0-9]//g' )
	if [ $( wc -l $outfile | sed 's/[^0-9]//g' ) -ne $nbtotal ] 
		then
		log "warning" "issue while comparing initial time dimension with the created vector file"
		return 1
	fi
}

function nctab2wnddirvector(){
	if [ $# -ne 3 ] 
		then
		log "warning" "bad use of nctab2wnddirvector function - missing or too much parameters"
		return 1
	fi
	infilenc=$1
	outfile=$3
	station=$2

	# retrieve column vector wnddir  from ounp-tab.nc file
	ncks -s "%f\n" -C -h -d station,$indexstation -v wnddir $infilenc | tail -n+14 | sed '$d' | sed '$d' > $outfile

	# dimension number of Time - for verification
	nbtotal=$( ncdump -h $infilenc | grep time | head -1 | sed 's/[^0-9]//g' )
	if [ $( wc -l $outfile | sed 's/[^0-9]//g' ) -ne $nbtotal ] 
		then
		log "warning" "issue while comparing initial time dimension with the created vector file"
		return 1
	fi
}