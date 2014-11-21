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
#
# La sortie du script sont des fichiers netcdf NM824-YYYY.nc où YYYY est l\'annee physique traitee.
######################################################################################################
source ./resources/sh/utility.sh

#!/bin/bash
if [ $# -ne 3 ] 
	then
	log $? "Usage: nemomed8orig2rec <path-to-inputs-dir> <path-to-outputs-dir> <year-of-inputs-fields>"
	exit 1
fi

## PARAMETERS ##
gridfile="grids/grids.nc"
variables="sosstsst vomecrty vozocrtx"
sstfile="sst.nc"
vomecrtyfile="vomecrty.nc"
vozocrtxfile="vozocrtx.nc"
lat="nav_lat"
lon="nav_lon"
workdir="work"
indir=$1
outdir=$2
## END PARAMETERS ##

# Interpolation parameters
# Must be larger than grid description in ww3_grid.inp
envelope="-R-7/19/29/47"
Xinc=0.125
Yinc=0.125

# nearneighbor sections/mandatory
paramN=-N6/1
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
	 
	log "notice" "a) ---- long/lat extractions ----"
	# extract lon/lat
	gmt grd2xyz $indir/$yearlync?$lon > $workdir/longitude
	log $? "Extract Longitude"
	gmt grd2xyz $indir/$yearlync?$lat > $workdir/latitude
	log $? "Extract Latitude"

	case "$yearlync" in
	"$sstfile")
		log "notice" "b) ---- sst regriding ----"
		var="sosstsst"
		;;
	"$vomecrtyfile")
		log "notice" "b) ---- vomecrty regriding ----"
		var="vomecrty"
		;;
	"$vozocrtxfile")
		log "notice" "b) ---- vozocrtx regriding ----"
		var="vozocrtx"
		;;
	esac

	# Prepare mask : 1 to land / Nan to water
	gmt grdlandmask $envelope -Df -I${Xinc}/${Yinc} -N1/NaN -G$workdir/land_mask.grd 

	#extract timesteps
	timesteps=$(ncdump -v time $indir/$yearlync | sed '1,40d' | awk '/[0-9],|[0-9] ;/ { print }' | awk ' {for (i=1; i<=NF; i++) {if ($i ~ /[0-9]/) {print $i}}}' | sed 's/,//g' | sed '1d' )
	log $? "Timesteps extraction"

	# log "warning" "debug mode please press [enter] -> only one timestep treated by var-file.nc"
	# timesteps=43200

	tindex=0
	for curtimestep in $timesteps; do
		# trick to print on three digits and avoid time gaps while ncrcatting
		curtimestep3d=$(printf "%03d" $(( ($curtimestep - 43200) / 86400 )))
		# curtimestep3D is the day number after the origin date: xx/xx/xx 12:00:00

		gmt grd2xyz $indir/$yearlync?$var[$tindex] > $workdir/current_flux
		log $? "extract $var[$index]"
		paste $workdir/longitude $workdir/latitude > $workdir/lonlat
		paste $workdir/lonlat $workdir/current_flux > $workdir/joined.xyz
		log $? "Join data in xyz file"

		awk '{ print  $3" "$6" "$9}' $workdir/joined.xyz > $workdir/$var-temp-$curtimestep3d.xyz
		# rm $workdir/joined.xyz

		# before interpolating, set land data to NAN to not be included into shoreline interpolation
		awk '{ if($3!=0) {print $1"	"$2"	"$3}; }' $workdir/$var-temp-$curtimestep3d.xyz > $workdir/$var-$curtimestep3d.xyz
		gmt nearneighbor $workdir/$var-$curtimestep3d.xyz $envelope -I${Xinc}/${Yinc} $paramN $paramS -G$outdir/$var-$curtimestep3d.grd
		log $? "Interpolation"
		
		# apply mask
		gmt grdmath $outdir/$var-$curtimestep3d.grd $workdir/land_mask.grd OR = $outdir/masked_$var-$curtimestep3d.grd
		#mv $outdir/$var-$curtimestep3d.grd $outdir/masked_$var-$curtimestep3d.grd
		log $? "Mask"
		
		# refractor var
		# ncrename -h -d x,longitude -d y,latitude -v x,longitude -v y,latitude -v z,$var $outdir/masked_$var-$curtimestep3d.grd
		ncrename -h -d lon,longitude -d lat,latitude -v lon,longitude -v lat,latitude -v z,$var $outdir/masked_$var-$curtimestep3d.grd
		log $? "ncrename dim&vars"
		ncatted -h -O -a long_name,longitude,d,f," " $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a long_name,longitude,c,c,"longitude"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a units,longitude,c,c,"degrees_east" $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a axis,longitude,c,c,"X"  $outdir/masked_$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,latitude,d,f," " $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a long_name,latitude,c,c,"latitude"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a units,latitude,c,c,"degrees_north"  $outdir/masked_$var-$curtimestep3d.grd
		ncatted -h -a axis,latitude,c,c,"Y"  $outdir/masked_$var-$curtimestep3d.grd
		
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
		# log "warning" "on debug should. uncomment here"
		rm $workdir/lonlat $workdir/current_flux $workdir/$var-$curtimestep3d.xyz $outdir/$var-$curtimestep3d.grd
	done ##end foreach timestep

ncrcat -O $outdir/masked_$var*.grd $outdir/$var-$outfile
log $? "NCRCAT grdfiles"
# log "warning" "on debug should. uncomment here"
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

