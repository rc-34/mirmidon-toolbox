#! /bin/bash

if [ $# -ne 0 ] ; then
	echo "Usage: ./extract.sh"
	exit -1
fi
#source utilities
source ./resources/sh/utility.sh
rightnow
log "notice" "Start... $d"


## PARAMETERS ##
envelope="-R2.18/6.80/41.30/43.70" #envelope considered
work="work"
inputs="inputs"
outputs="outputs"
sitefile="inputs/sites.xy"
variables="hs lm t01 dir"
################
rm -Rf $work
if [ ! -d $work ] ; then
	mkdir $work
fi

# read sites list
#sites=$( awk '{print $3}' inputs/sites.xy | sed 's/[^0-9]*//g' )
#for test : 
sites=$( head inputs/sites.xy | awk '{print $3}'  | sed 's/[^0-9]*//g' )

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
			log "notice" "site: node[$site]"

			# extract var
			ncks -v hs -d node,$site $infile  | sed '1,25d' > $work/$monthlyfile-hs-$site-tmp
			ncks -v lm -d node,$site $infile  | sed '1,25d' > $work/$monthlyfile-lm-$site-tmp
			ncks -v t01 -d node,$site $infile  | sed '1,25d' > $work/$monthlyfile-t01-$site-tmp
			ncks -v dir -d node,$site $infile  | sed '1,25d' > $work/$monthlyfile-dir-$site-tmp
			log $? "hs lm t01 dir extraction"

			# join time and hs
			grep hs $work/$monthlyfile-hs-$site-tmp | awk '{print $3"\t"$2}' | awk 'BEGIN {FS = "="} {print $2}' > $work/$monthlyfile-hs-$site-tmp2
			cat -n $work/$monthlyfile-hs-$site-tmp2 > $work/$monthlyfile-hs-$site-tmp
			join $work/$monthlyfile-time $work/$monthlyfile-hs-$site-tmp | awk '{print $2"\t"$3"\t"$4}' > $work/$monthlyfile-hs-$site
			log $? "hs join"

			# join time and lm
			grep lm $work/$monthlyfile-lm-$site-tmp | awk '{print $3"\t"$2}' | awk 'BEGIN {FS = "="} {print $2}' > $work/$monthlyfile-lm-$site-tmp2
			cat -n $work/$monthlyfile-lm-$site-tmp2 > $work/$monthlyfile-lm-$site-tmp
			join $work/$monthlyfile-time $work/$monthlyfile-lm-$site-tmp | awk '{print $2"\t"$3"\t"$4}' > $work/$monthlyfile-lm-$site
			log $? "lm join"

			# join time and t01
			grep t01 $work/$monthlyfile-t01-$site-tmp | awk '{print $3"\t"$2}' | awk 'BEGIN {FS = "="} {print $2}' > $work/$monthlyfile-t01-$site-tmp2
			cat -n $work/$monthlyfile-t01-$site-tmp2 > $work/$monthlyfile-t01-$site-tmp
			join $work/$monthlyfile-time $work/$monthlyfile-t01-$site-tmp | awk '{print $2"\t"$3"\t"$4}' > $work/$monthlyfile-t01-$site
			log $? "t01 join"

			# join time and dir
			grep dir $work/$monthlyfile-dir-$site-tmp | awk '{print $3"\t"$2}' | awk 'BEGIN {FS = "="} {print $2}' > $work/$monthlyfile-dir-$site-tmp2
			cat -n $work/$monthlyfile-dir-$site-tmp2 > $work/$monthlyfile-dir-$site-tmp
			join $work/$monthlyfile-time $work/$monthlyfile-dir-$site-tmp | awk '{print $2"\t"$3"\t"$4}' > $work/$monthlyfile-dir-$site
			log $? "dir join"

			# clean
			rm $work/*-tmp*
		done # END -> for each site
	done # END -> for each month of the current year
	
	if [ ! -d $outputs/$year ] ; then
		mkdir $outputs/$year
	fi
	for site in $sites ; do
		if [ ! -d $outputs/$year/$site ] ; then
			mkdir $outputs/$year/$site
		fi

		cat $work/*-hs-$site >> $work/$year-hs-$site.tmp
		sort -u $work/$year-hs-$site.tmp > $outputs/$year/$site/$year-hs-$site.dat
		log $? "sort hs file"

		cat $work/*-lm-$site >> $work/$year-lm-$site.tmp
		sort -u $work/$year-lm-$site.tmp > $outputs/$year/$site/$year-lm-$site.dat
		log $? "sort lm file"

		cat $work/*-t01-$site >> $work/$year-t01-$site.tmp
		sort -u $work/$year-t01-$site.tmp > $outputs/$year/$site/$year-t01-$site.dat
		log $? "sort t01 file"

		cat $work/*-dir-$site >> $work/$year-dir-$site.tmp
		sort -u $work/$year-dir-$site.tmp > $outputs/$year/$site/$year-dir-$site.dat
		log $? "sort dir file"
	done
done

rightnow
log "notice" "End... $d"