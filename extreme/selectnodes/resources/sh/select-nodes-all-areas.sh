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

	longmin[0]=3.
	longmax[0]=5.25
	latmin[0]=42.25
	latmax[0]=43.5

	longmin[1]=3.
	longmax[1]=5.5
	latmin[1]=42.
	latmax[1]=43.40

	longmin[2]=3.
	longmax[2]=6
	latmin[2]=41.75
	latmax[2]=43.25

	longmin[3]=3.
	longmax[3]=6.80
	latmin[3]=41.30
	latmax[3]=43.15

	longmin[4]=3.
	longmax[4]=6.80
	latmin[4]=41.30
	latmax[4]=43.

	# for each section
	for i in $(seq 0 $(($k-1))); do
		# nb nodes to select
		nbtoselect=$(($initsitesnb - ($incsites * $i)))
		echo $nbtoselect
		
		# get min and max from the subset
		# lonmin=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $5 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $1} ')
		# lonmax=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $5 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $2} ')

		# latmin=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $6 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $1} ')
		# latmax=$(gmt gmtinfo $work/nodes-$i.xyz | awk '{ print $6 }' | sed 's/>//' |sed 's/<//' | awk 'BEGIN {FS = "/"} {print $2} ')
		lonmin=${longmin[$i]}
		lonmax=${longmax[$i]}
		latmin=${latmin[$i]}
		latmax=${latmax[$i]}

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

		cat $work/lhs-Rprojeted-$i.xy |sed 's/\"//g' | awk '{print $2"	"$3"	"$4}' > $work/lhs-projeted-$i.xy
		sort -u $work/lhs-projeted-$i.xy > $work/sites-$i.xy

	done

	# finally collect all chosennode in one file
	if [ -f $work/sites.xy ] ; then
		rm $work/sites.xy
	fi
	for i in $(seq 0 $(($k-1))); do
		cat $work/sites-$i.xy >> $outputs/sites.xy
	done

}