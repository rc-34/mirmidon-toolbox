#! /bin/bash

if [ $# -ne 1 ] ; then
	echo "Usage: ./selectnodes.sh <inputfile>"
	exit -1
fi
#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "Start... $d"

## PARAMETERS ##
k=1 #number of levels in z axis
envelope="-R2.18/6.80/41.30/43.70" #envelope considered
envelope="-R3/5/42.25/43.60" #envelope considered
initsitesnb=100
incsites=$((initsitesnb/$k))

work="work"
inputs="inputs"
outputs="outputs"
if [ ! -d $work ] ; then
	mkdir $work
fi
flux=$1


#create areas files regarding the bathymetry section 
# source ./resources/sh/create-xyz-areas.sh
# createxyzareas $flux
nodefile="inputs/nodes.xyz"

# #select randomly nodes over the areas
source ./resources/sh/select-nodes-all-areas.sh
selectnodes $nodefile k

#plot
source ./resources/sh/plot-selected-nodes.sh


rightnow
log "notice" "End... $d"