#######################################################################################################
#											INFO													  #
#######################################################################################################
# Le but de ce script est de reformatter les données des grilles NM8-24 sur une unique grille de
# référence, et reguliere.
# Le script doit être lancé à partir d un dossier dans lequel on trouve :
#
# 1) le fichier grids.nc dans le dossier ""grids"
# 2) un dossier work qui est généré à l'execution qui contient les fichiers temporaires
# 3) un dossier "outputs" qui contiendra les fichiers NM824-YYYY.nc
# 4) un dossier "inputs" qui contient les données brutes (.tar.gz)
#
######################################################################################################

#!/bin/bash

if [ $# -ne 3 ] 
	then
	echo "Usage: ug2rec-2D <in-file> <out-file> "
	exit 1
fi

## PARAMETERS ##
lat="latitude"
lon="longitude"
workdir="work"
indir=$1
outdir=$2
variable="hs "
## END PARAMETERS ##

# Interpolation parameters
# Must be larger than grid description in ww3_grid.inp
envelope="-R-7/19/29/47"
Xinc=0.125
Yinc=0.125

# nearneighbor sections/mandatory
#paramN=-N360/20
paramN=-N4/2
# nearneighbor radius of circle (using Xinc)
paramS=-S0.5


if [ ! -d $outdir ]
	then
	mkdir $outdir
fi

#define origin time
month=${fluxfilename:14:2}
year=$3
dateorg=$year"0101 12:00:00"
origin=$(date -j  -f '%Y%m%d %H:%M:%S' "$dateorg" +'%Y-%m-%d %H:%M:%S')
outfile="NM824REC-"$year".nc"

#start regridding
for yearlync in $( ls $indir ) ; do
	# select file and variable to work on
	var=""
	 
	echo "a) ---- long/lat extractions ----"
	# extract lon/lat
	grd2xyz -V $indir/$yearlync?$lon > $workdir/longitude
	grd2xyz -V $indir/$yearlync?$lat > $workdir/latitude

	case "$yearlync" in
	"$sstfile")
		echo "b) ---- sst regriding ----"
		var="sosstsst"
		;;
	"$vomecrtyfile")
		echo "b) ---- vomecrty regriding ----"
		var="vomecrty"
		;;
	"$vozocrtxfile")
		echo "b) ---- vozocrtx regriding ----"
		var="vozocrtx"
		;;
	esac

	#Prepare mask : 1 to land / Nan to water
	grdlandmask -V $envelope -Df -I${Xinc}/${Yinc} -N1/NaN -G$workdir/land_mask.grd 

	#extract timesteps
	timesteps=$(ncdump -v time $indir/$yearlync | sed '1,40d' | awk '/[0-9],|[0-9] ;/ { print }' | awk ' {for (i=1; i<=NF; i++) {if ($i ~ /[0-9]/) {print $i}}}' | sed 's/,//g' | sed '1d' )

	#echo "debug mode please press [enter] -> only one timestep treated by var-file.nc"
	#read
	#timesteps=43200
	tindex=0
	for curtimestep in $timesteps; do
		# trick to print on three digits and avoid time gaps while ncrcatting
		curtimestep3d=$(printf "%03d" $(( ($curtimestep - 43200) / 86400 )))
		#curtimestep3D is the day number after the origin date: xx/xx/xx 12:00:00

		grd2xyz -V $indir/$yearlync?$var[$tindex] > $workdir/current_flux
		join $workdir/longitude $workdir/latitude > $workdir/temp
		join $workdir/temp $workdir/current_flux > $workdir/joined.xyz
		rm $workdir/temp
		rm $workdir/current_flux

		awk '{ print  $3" "$5" "$7}' $workdir/joined.xyz > $workdir/$var-temp-$curtimestep3d.xyz
		#awk '{ print  $3" "$5" "$7}' $workdir/joined.xyz > $workdir/$var-$curtimestep3d.xyz
		rm $workdir/joined.xyz

		#interpolation
		#before interpolating, set land data to NAN to not be included into shoreline interpolation
		awk '{ if($3!=0) {print $1"	"$2"	"$3}; }' $workdir/$var-temp-$curtimestep3d.xyz > $workdir/$var-$curtimestep3d.xyz
		nearneighbor -V $workdir/$var-$curtimestep3d.xyz $envelope -I${Xinc}/${Yinc} $paramN $paramS -G$outdir/$var-$curtimestep3d.grd
		rm $workdir/$var-$curtimestep3d.xyz $workdir/$var-temp-$curtimestep3d.xyz

		# apply mask
		grdmath -V $outdir/$var-$curtimestep3d.grd $workdir/land_mask.grd OR = $outdir/masked_$var-$curtimestep3d.grd
		rm $outdir/$var-$curtimestep3d.grd

		# refractor output file
		ncrename -h -v x,longitude -v y,latitude -v z,$var $outdir/masked_$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,longitude,d,f," " $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a long_name,longitude,c,c,"longitude"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a units,longitude,c,c,"degrees_east" $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a axis,longitude,c,c,"X"  $outdir/masked_$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,latitude,d,f," " $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a long_name,latitude,c,c,"latitude"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a units,latitude,c,c,"degrees_north"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a axis,latitude,c,c,"Y"  $outdir/masked_$var-$curtimestep3d.grd
		
		ncrename -h -d x,longitude -d y,latitude $outdir/masked_$var-$curtimestep3d.grd
		
		#add variable time and set time with current time step
		ncap -h -O -s "time=$tindex" $outdir/masked_$var-$curtimestep3d.grd $outdir/masked_$var-$curtimestep3d.grd
		#add meta data on time variable
		ncatted -h -a calendar,time,c,c,"gregorian" $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a long_name,time,c,c,"time"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a units,time,c,c,"days since $origin"  $outdir/masked_$var-$curtimestep3d.grd

		#store lon/lat, delete lon/lat
		ncks -h -O -v longitude,latitude $outdir/masked_$var-$curtimestep3d.grd $workdir/templonlat.nc
		ncks -h  -O -x -v longitude,latitude $outdir/masked_$var-$curtimestep3d.grd $outdir/masked_$var-$curtimestep3d.grd
		
		#add dimension time
		ncecat -h -O -u time $outdir/masked_$var-$curtimestep3d.grd $outdir/masked_$var-$curtimestep3d.grd
		
		#restore lon/lat
		ncks -h -A $workdir/templonlat.nc $outdir/masked_$var-$curtimestep3d.grd

		tindex=$(( $tindex +1 ))
		
	done ##end foreach timestep

ncrcat $outdir/masked_$var*.grd $outdir/$var-$outfile
rm $outdir/*.grd

unit=""
if [ "$var" == "vomecrty" ] || [ "$var" == "vozocrtx" ]
	then
	unit="m/s"
elif [ "$var" == "sosstsst" ]
	then
	unit="C"
fi
ncatted -h -a units,$var,c,c,"$unit"  $outdir/$var-$outfile
ncatted -h -O -a long_name,$var,d,f," " $outdir/$var-$outfile
ncatted -h -a long_name,$var,c,c,"$var"  $outdir/$var-$outfile
ncatted -h -a standard_name,$var,c,c,"$var"  $outdir/$var-$outfile
ncatted -h -a coordinates,$var,c,c,"longitude latitude"  $outdir/$var-$outfile

done ##end foreach var

