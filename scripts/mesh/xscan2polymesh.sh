#######################################################################################################
#											INFO													  #
#######################################################################################################
# Routine pour convertir les fichiers .scan extraits de xscan en fichier compatibles polymesh >= v2.1
#
# La routine prend pour arguments: 
# 1) Le fichier de contour
# 2) Le fichier des iles
#######################################################################################################

#!/bin/bash

if [ $# -ne 2 ] 
	then
	echo "Usage: ./xscan2polymesh.sh <path-to-xscan-contour-file> <path-to-xscan-island-file>"
	echo "example: ./xscan2polymesh.sh ./med500-contour.scan ./med500-island.scan"
	exit 1
fi

## PARAMETERS ##
contour=$1
island=$2
randfile="rand.dat"
inselfile="insel.dat"
workdir="work"
## END PARAMETERS ##

# 1) clean
rm -R $workdir
rm $randfile
rm $inselfile

mkdir -p $workdir

polygon_rank=0

## CONTOUR ##
echo "Working on $contour to construct contours..."
echo "C Insel		$polygon_rank" >> $randfile

# extract contour nodes
cat $contour | grep "\." >> $workdir/alpha
awk '{print $2"	"$3 }' $workdir/alpha >> $workdir/beta

# print rows (nodenumber -- i.e. row -- , lon, lat, -10.000000)
nl -s "	" $workdir/beta >> $workdir/gama
awk '{print	"	"$1"	"$2"	"$3"	-10.000000"}' $workdir/gama >> $workdir/epsilon

cat $workdir/epsilon >> $randfile
echo "    -1" >> $randfile

echo "End of contours!"
## ISLAND ##
echo "Working on $island to construct islands..."
# select groups
cat $island | grep -v "\." | awk '{print $2}' >> $workdir/islandgroups
cat $island | grep "\." >> $workdir/islands

row=$(wc -l $workdir/beta | awk '{print $1}')

# Value to finalize file
count=$(wc -l $workdir/islandgroups | awk '{print $1}')
loop=1
for i in $(cat $workdir/islandgroups) ; do 
	polygon_rank=$((polygon_rank + 1))
	echo "C Insel		$polygon_rank" >> $inselfile

	head -n $i $workdir/islands > $workdir/islandcurrentgroup
	#delete head of files
	#sed '1,$i d'
	length=$(wc -l $workdir/islands | awk '{print $1}')
	newlength=$(($length - $i))
	tail -n $newlength $workdir/islands > $workdir/tmp
	cat $workdir/tmp > $workdir/islands

	# print all line of a group
	while read line
	do
		row=$(($row + 1))
		coord=$(echo $line | awk '{print $2"	"$3}')
		echo "	$row 	$coord	-10.000000" >> $inselfile
	done < $workdir/islandcurrentgroup
	
	if [ $loop -eq $count ] ; 
		then
		echo "    -2" >> $inselfile	
	else
		# end group
		echo "    -1" >> $inselfile	
	fi
	loop=$(($loop + 1))
done

echo "End of islands!"

echo "Clearing rand.dat"
awk '{if ($2 ~/E/) {split($2,a,"E"); b=a[1]*10^a[2]; print "	"$1"	"b"	"$3"	"$4 ; } else {print $0} }' $randfile > $workdir/tmprand1
awk '{if ($3 ~/E/) {split($3,a,"E"); b=a[1]*10^a[2]; print "	"$1"	"$2"	"b"	"$4 ; } else {print $0} }' $workdir/tmprand1 > $randfile
echo "Clearing Insel.dat"
awk '{if ($2 ~/E/) {split($2,a,"E"); b=a[1]*10^a[2]; print "	"$1"	"b"	"$3"	"$4 ; } else {print $0} }' $inselfile > $workdir/tmpinsel1
awk '{if ($3 ~/E/) {split($3,a,"E"); b=a[1]*10^a[2]; print "	"$1"	"$2"	"b"	"$4 ; } else {print $0} }' $workdir/tmpinsel1 > $inselfile

echo "That's all folks!!!"

