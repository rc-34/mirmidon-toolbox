#! /bin/bash

if [ $# -ne 1 ] ; then
	echo "Usage: ./extract.sh var<hs t01 lm dir>"
	exit -1
fi
#source utilities
source ./resources/sh/utility.sh
source ./resources/sh/extractvar.sh
rightnow
log "notice" "Start... $d"


## PARAMETERS ##
envelope="-R2.18/6.80/41.30/43.70" #envelope considered
work="work"
inputs="inputs"
outputs="outputs"
sitefile="inputs/sites.xy"
var=$1
################
# rm -Rf $work
if [ ! -d $work ] ; then
	mkdir $work
fi

# read sites list
sites=$( awk '{print $3}' inputs/sites.xy | sed 's/[^0-9]*//g' )
#for test : 
#sites=$( head inputs/sites.xy | awk '{print $3}'  | sed 's/[^0-9]*//g' )

# for each year available
for year in $(ls "$inputs/ounf/") ; do
	log "notice" "Year: $year..."
	# for each month of the current year
	for monthlyfile in $(ls "inputs/ounf/$year/" | grep $year) ; do
		infile=inputs/ounf/$year/$monthlyfile
		log "notice" "Monthly file: $infile..."
		
		# time column
		cdo showtimestamp $infile | sed 's/  /\'$'\n/g' | sed '1d' > $work/$monthlyfile-time-tmp
		log $? "time extraction"
		cat -n $work/$monthlyfile-time-tmp > $work/$monthlyfile-time

		# for each site get variables
		for site in $sites ; do

			extract $site $infile $monthlyfile $var &

			# clean
			# rm $work/*-tmp*
		done # END -> for each site
		log "notice" "waiting all child processes to finish"
		wait
		log "notice" "waiting done"
	done # END -> for each month of the current year
	
	if [ ! -d $outputs/$year ] ; then
		mkdir $outputs/$year
	fi
	for site in $sites ; do
		if [ ! -d $outputs/$year/$site ] ; then
			mkdir $outputs/$year/$site
		fi

		cat $work/*-$var-$site >> $work/$year-$var-$site.tmp
		sort -u $work/$year-$var-$site.tmp > $outputs/$year/$site/$year-$var-$site.dat
		log $? "sort $var file"

	done
done

rightnow
log "notice" "End... $d"