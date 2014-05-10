#! /bin/bash


function createxyzareas(){
	## PROCESS GRID POINTS FROM WW3-4.18 ounf outputs ##
	ncfile="file.nc"
	if [ ! -f $work/$ncfile ] ; then
		ncks -F -d time,1 $flux $work/$ncfile
		log $? "timeframe extraction"	
	fi

	#lon 
	ncks -v longitude $flux |sed '1,11d'  > $work/longitude.ncks
	awk '{print $1"="$2}' $work/longitude.ncks > $work/longitude.ncks2
	awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/longitude.ncks2 > $work/longitude
	log $? "long extraction"

	#lat
	ncks -v latitude $flux |sed '1,11d'  > $work/latitude.ncks
	awk '{print $1"="$2}' $work/latitude.ncks > $work/latitude.ncks2
	awk 'BEGIN { FS = "=" } ;{print $1"	"$3}' $work/latitude.ncks2 > $work/latitude
	log $? "lat extraction"

	#dpt
	ncks -F -v dpt -d time,1  $flux |sed '1,25d' > $work/dpt.ncks
	awk 'BEGIN { FS = "="; i=0;}; {if ($3 ~ /.*_.*/) {print "node["i"]  0.00 m"} else {print "node["i"]  "$3} ; i=i+1 } '  $work/dpt.ncks > $work/dpt.ncks2
	## to modify to make it generic ##
	sed  '47087,47089d' $work/dpt.ncks2 > $work/dpt.ncks
	##################################
	awk '{print $1"	"$2}' $work/dpt.ncks > $work/dpt
	log $? "dpt extraction"

	join $work/longitude $work/latitude  > $work/lonlat.xy
	join $work/lonlat.xy $work/dpt > $work/nodes.xyz
	awk  '{print $2"	"$3"	"$4"	"$1}' $work/nodes.xyz > $inputs/nodes.xyz
	log $? "join node in a lonlat file"

}