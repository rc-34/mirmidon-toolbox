#! /bin/bash

function extract {
	site=$1
	infile=$2
	monthlyfile=$3
	var=$4
	work=work

	log "notice" "site: node[$site]"

	# extract var
	ncks -v $var -d node,$site $infile  | sed '1,25d' > $work/$monthlyfile-$var-$site-tmp
	log $? "$var extraction"

	# join time and dir
	grep $var $work/$monthlyfile-$var-$site-tmp | awk '{print $3"\t"$2}' | awk 'BEGIN {FS = "="} {print $2}' > $work/$monthlyfile-$var-$site-tmp2
	cat -n $work/$monthlyfile-$var-$site-tmp2 > $work/$monthlyfile-$var-$site-tmp
	join $work/$monthlyfile-time $work/$monthlyfile-$var-$site-tmp | awk '{print $2"\t"$3"\t"$4}' > $work/$monthlyfile-$var-$site
	log $? "$var join"

	log $? "$var-$site extraction"
}