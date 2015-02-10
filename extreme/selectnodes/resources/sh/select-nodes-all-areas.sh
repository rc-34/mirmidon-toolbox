#! /bin/bash

function selectnodes(){
	allnodesfile=$1
	# extract only point from the selected area
	gmt gmtselect $allnodesfile $envelope > $work/nodes-envelope.xyz

	zmin=0
	zmax=$(gmt gmtinfo $work/nodes-envelope.xyz | awk '{ print $7 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $2} ')

	# get sections range
	section[0]=8.0 # to avoid taking to narrow coastline points
	#echo ${section[0]}
	Rscript resources/R/a.R $zmax $k | awk '{print $2}' > $work/sectionarray.txt
	for i in $(seq 1 $k); do
		section[$i]=$(head -$i $work/sectionarray.txt|tail -1)
		echo ${section[$i]}
	done
	log $? "($k)section(s) definition, from ${section[0]}m to ${section[$k]}m" 


	# for each section split the $work/nodes-envelope.xyz file into a new nodes-<level>.xyz file
	for i in $(seq 0 $(($k-1))); do
		gmt gmtselect $work/nodes-envelope.xyz $envelope -Z${section[$i]}/${section[$(($i+1))]} > $work/nodes-$i.xyz
	done
	log $? "nodes per section selection"

	# for each section
	for i in $(seq 0 $(($k-1))); do
		# nb nodes to select
		nbtoselect=$(($initsitesnb - ($incsites * $i)))
		echo $nbtoselect
		
		# get min and max from the subset
		lonmin=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $5 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $1} ')
		lonmax=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $5 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $2} ')

		latmin=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $6 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $1} ')
		latmax=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $6 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $2} ')
		

		# generate a lhs
		Rscript resources/R/lhs.R $nbtoselect $lonmin $lonmax $latmin $latmax | sed '1d' > $work/lhs-$i.txt
		
		# extract only lon lat point
		awk '{print $2"	"$3}' $work/lhs-$i.txt > $work/lhs-$i.xy

		# for each point in lhs-$i.xy find and store the closest grid point
		if [ -f $work/lhs-Rprojeted-$i.xy ] ; then
			rm $work/lhs-Rprojeted-$i.xy 
		fi
		while read line
		do
			Rscript resources/R/nearest.R $work/nodes-$i.xyz $line >> $work/lhs-Rprojeted-$i.xy
		done < $work/lhs-$i.xy

		cat $work/lhs-Rprojeted-$i.xy |sed 's/\"//g' | awk '{print $2"	"$3"	"$4"	"$5}' > $work/lhs-projeted-$i.xyz
		sort -u $work/lhs-projeted-$i.xyz > $work/sites-$i.xyz

	done

	# finally collect all chosennode in one file
	if [ -f $outputs/sites.xy ] ; then
		rm $outputs/sites.xyz
	fi
	for i in $(seq 0 $(($k-1))); do
		cat $work/sites-$i.xyz >> $outputs/sites.xyz
	done

}