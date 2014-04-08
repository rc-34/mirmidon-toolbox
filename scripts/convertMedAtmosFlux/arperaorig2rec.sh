#######################################################################################################
#											INFO													  #
#######################################################################################################
# Le but de ce script est de reformatter les données d\'une grille 
# curvilineaire ARPERACUR sur une grille régulière ARPERAREC.
# Le script doit être lancé à partir d un dossier dans lequel on trouve :
#
# 1) le fichier grids.nc dans le dossier ""grids"
# 2) un dossier work qui est généré à l'execution qui contient les fichiers temporaires
# 3) un dossier "outputs" qui contiendra le fichier ARPERAREC-YYYYMM.nc
#
# On donne à l'execution le path vers le fichier de flux arpara concaténé sur un an qui contient
# l\'ensemble des variables (voir convertArperaFlux dans TOOLS).
#
# La sortie du script est un fichier netcdf ARPERAREC-YYYYMM.nc où YYYYMM est le mois physique traite.
# Il est ensuite utilisé dans un script parent pour concatener tous les mois d une annee physique.
######################################################################################################

#!/bin/bash

if [ $# -ne 1 ] 
	then
	echo "Usage: ./arperaorig2rec.sh <monthly-arpera-flux-file>"
	exit 1
fi

## PARAMETERS ##
gridfile="grids/grids.nc"
fluxfile=$1
fluxfilename=$(ls $1 |sed 's/.*\(...................\)$/\1/')
variables="UX10 VY10 TCLS TSUR"
#variables="UX10"
workdir="work"
outdir="outputs"

#outfile1=$(ls $1 |sed 's/.nc/.ps/')

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."title":WeSn

gmtset PAPER_MEDIA a4
gmtset Y_AXIS_TYPE ver_text
gmtset BASEMAP_TYPE fancy+
gmtset HEADER_FONT Helvetica
gmtset HEADER_FONT_SIZE 14p
gmtset HEADER_OFFSET 0.5c
gmtset FRAME_WIDTH 0.08c
gmtset ANNOT_FONT_SIZE 8p
gmtset ANNOT_OFFSET_PRIMARY 0.1c
gmtset LABEL_FONT_SIZE 8p
gmtset LABEL_OFFSET 0.2c
gmtset D_FORMAT %8.8f
## END PARAMETERS ##

# Interpolation parameters
# Must be larger than grid description in ww3_grid.inp
envelope="-R-7/19/29/47"
Xinc=0.125
Yinc=0.125

# nearneighbor sections/mandatory
#paramN=-N360/20
paramN=-N10/2
# nearneighbor radius of circle (using Xinc)
paramS=-S1

#define origin time
month=${fluxfilename:14:2}
year=${fluxfilename:10:4}
dateorg=$year$month"01 00:00:00"
origin=$(date -j  -f '%Y%m%d %H:%M:%S' "$dateorg" +'%Y-%m-%d %H:%M:%S')
outfile="ARPERAREC-"$year$month".nc"

# 1) clean & init
rm -Rf $workdir
mkdir $workdir
if [ -f $outdir/$year/$month/$outfile ]
	then
	rm -f $outdir/$year/$month/$outfile
fi 

#extract long/lat
grd2xyz -V ${gridfile}?medh.lon > $workdir/longitude
grd2xyz -V ${gridfile}?medh.lat > $workdir/latitude 

#extract timesteps
#timesteps=$(ncdump -v time $fluxfile | sed '1,40d' | awk '/[0-9],|[0-9] ;/ { print }' | awk ' {for (i=1; i<=NF; i++) {if ($i ~ /[0-9]/) {print $i}}}' | sed 's/,//g' )
timesteps=$(ncdump -v time $fluxfile | sed '1,13d' | awk '/[0-9],|[0-9] ;/ { print }' | awk ' {for (i=1; i<=NF; i++) {if ($i ~ /[0-9]/) {print $i}}}' | sed 's/,//g' )
# 2) foreach variable
for var in $variables; do
	
	# 3) foreach timestep
	## TODO:REMOVE THE FOLLOWING LINE TO MANIPULATE ALL TIME STEPS ##
	#timesteps=0
	
	tindex=0
	
	for curtimestep in $timesteps; do
		# trick to print on three digits and avoid time gaps while ncrcatting
		curtimestep3d=$(printf "%03d" $curtimestep)
		
		#echo "TODO3 : regrid data for var ${var} and timestep ${curtimestep}"
		grd2xyz -V ${fluxfile}?$var[$tindex] > $workdir/current_flux

		join $workdir/longitude $workdir/latitude > temp
		join temp $workdir/current_flux > joined.xyz
		rm temp
		rm $workdir/current_flux

		awk '{ print  $3" "$5" "$7}' joined.xyz > $workdir/$var-$curtimestep3d.xyz
		rm joined.xyz

		#interpolation
		nearneighbor -V $workdir/$var-$curtimestep3d.xyz $envelope -I${Xinc}/${Yinc} $paramN $paramS -G$workdir/$var-$curtimestep3d.grd
		rm $workdir/$var-$curtimestep3d.xyz

		#1 to land / Nan to water
		#grdlandmask -V $envelope -Df -I${Xinc}/${Yinc} -N1/NaN -Gland_mask.grd 

		# apply mask
		#grdmath -V flux_without_mask.grd land_mask.grd OR = masked_flux.grd 

		# refractor output file
		ncrename -h -v x,longitude -v y,latitude -v z,$var $workdir/$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,longitude,d,f," " $workdir/$var-$curtimestep3d.grd
		ncatted -h -a long_name,longitude,c,c,"longitude"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a units,longitude,c,c,"degrees_east"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a axis,longitude,c,c,"X"  $workdir/$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,latitude,d,f," " $workdir/$var-$curtimestep3d.grd
		ncatted -h -a long_name,latitude,c,c,"latitude"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a units,latitude,c,c,"degrees_north"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a axis,latitude,c,c,"Y"  $workdir/$var-$curtimestep3d.grd
		
		ncrename -h -d x,longitude -d y,latitude $workdir/$var-$curtimestep3d.grd
		
		#add variable time and set time with current time step
		ncap -h -O -s "time=$curtimestep" $workdir/$var-$curtimestep3d.grd $workdir/$var-$curtimestep3d.grd
		#add meta data on time variable
		ncatted -h -a calendar,time,c,c,"gregorian" $workdir/$var-$curtimestep3d.grd
		ncatted -h -a long_name,time,c,c,"time"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a units,time,c,c,"hours since $origin"  $workdir/$var-$curtimestep3d.grd

		#store lon/lat, delete lon/lat
		ncks -h -O -v longitude,latitude $workdir/$var-$curtimestep3d.grd templonlat.nc
		ncks -h  -O -x -v longitude,latitude $workdir/$var-$curtimestep3d.grd $workdir/$var-$curtimestep3d.grd
		
		#add dimension time
		ncecat -h -O -u time $workdir/$var-$curtimestep3d.grd $workdir/$var-$curtimestep3d.grd
		
		#restore lon/lat
		ncks -h -A templonlat.nc $workdir/$var-$curtimestep3d.grd

		#increment time index
		tindex=$((tindex + 1))
	done ##end foreach timestep

# 4) concat each time step
echo "STEP4 : concat timestep for variable ${var}"
echo "ncrcat $workdir/$var*.grd $workdir/$var-$outfile"
ncrcat $workdir/$var*.grd $workdir/$var-$outfile
unit=""
if [ "$var" == "UX10" ] || [ "$var" == "VY10" ]
	then
	unit="m/s"
elif [ "$var" == "TCLS" ] || [ "$var" == "TSUR" ]
	then
	unit="Kelvin"
fi
ncatted -h -a units,$var,c,c,"$unit"  $workdir/$var-$outfile
ncatted -h -O -a long_name,$var,d,f," " $workdir/$var-$outfile
ncatted -h -a long_name,$var,c,c,"$var"  $workdir/$var-$outfile
ncatted -h -a standard_name,$var,c,c,"$var"  $workdir/$var-$outfile
ncatted -h -a coordinates,$var,c,c,"longitude latitude"  $workdir/$var-$outfile

done ##end foreach var

# 5) finally join variables
echo "STEP5 : join all freshly concatened files for each variables into one"
for ncfile in $workdir/*.nc ; do
	echo "ncks -A $ncfile $outfile..."
	mkdir -p $outdir/$year/$month
	ncks -A $ncfile $outdir/$year/$month/$outfile
done

echo "STEP6 : clean"
rm $workdir/*.grd
#rm $workdir/*.nc

echo "...That's all folks!"
