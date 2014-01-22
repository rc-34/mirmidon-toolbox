#######################################################################################################
#											INFO													  #
#######################################################################################################
# Converter from msh format two kml file -- compatible with google earth --
#
# The user needs to specify the absolute or relative path to the mshfile to be converted
#######################################################################################################

#!/bin/bash

if [ $# -ne 1 ]
	then
	echo "Usage: ./msh2kml.sh <path-to-msh-file> "
	exit 1
fi

## PARAMETERS ##
mshfile=$1
outfile="mesh.kml"
workdir="work"
iconSrc="http://maps.google.com/mapfiles/kml/paddle/ylw-circle-lv.png"
## END PARAMETERS ##

# Header
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $outfile
echo "<kml xmlns=\"http://www.opengis.net/kml/2.2\">" >> $outfile

echo "<Style id=\"My_Style\">
  <IconStyle> <Icon> <href>"$iconSrc"</href> </Icon></IconStyle>
</Style>" >> $outfile

echo "<Folder>" >> $outfile
# create workdir
if [ ! -d $workdir ]
	then
	mkdir $workdir
fi

# cut off header of msh file
sed '1,4d' $mshfile > $workdir/nodestmp

# detect nodes number
nodes=$( head -1 $workdir/nodestmp )
sed '1,1d' $workdir/nodestmp > $workdir/nodestmp2
head -n $nodes $workdir/nodestmp2 > $workdir/nodestmp

# for each node create a placemark
awk 'BEGIN {i=1;}
    {
	print "<Placemark>";
	print "  <styleUrl> #My_Style</styleUrl>";
	print "  <name>"i"</name>";
	print "  <Point>";
	print "    <coordinates>"$2","$3","$4"</coordinates>";
	print "  </Point>";
	print "</Placemark>";
	i++;
	}' $workdir/nodestmp >> $outfile

# Footer
echo "</Folder>" >> $outfile
echo "</kml>" >> $outfile



echo "That's all folks!!!"

