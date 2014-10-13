#!/bin/bash
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
source ./resources/sh/utility.sh

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
# variables="UX10"
workdir="work"
outdir="outputs"

paramJ=-JM20c
paramB=-Bf5a10:longitude:/f2.5a5:latitude:/:."title":WeSn
gmt gmtset PS_MEDIA a3
gmt gmtset MAP_ANNOT_ORTHO ver_text
gmt gmtset MAP_FRAME_TYPE fancy+
gmt gmtset MAP_FRAME_WIDTH 0.08c
gmt gmtset FONT_TITLE Helvetica
gmt gmtset FONT_TITLE 14p
gmt gmtset MAP_TITLE_OFFSET 0.3c
gmt gmtset FONT_LABEL 8p
gmt gmtset MAP_LABEL_OFFSET 0.2c
gmt gmtset FORMAT_FLOAT_OUT %8.8f
## END PARAMETERS ##

# Interpolation parameters
# Must be larger than grid description in ww3_grid.inp
envelope="-R-7/19/29/47"
Xinc=50k
Yinc=50k

# nearneighbor sections/mandatory
paramN=-N10/1
# nearneighbor radius of circle (using Xinc)
paramS=-S40k

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
log $? "STEP 1: Init for $outdir/$year/$month/$outfile"

#extract long/lat
ncks -v medh.lon ${gridfile}  | sed '1,5d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $2}' > $workdir/longitude
ncks -v medh.lat ${gridfile}  | sed '1,5d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $2}' > $workdir/latitude
log $? "STEP2: Extract origin points coordinates"
paste $workdir/longitude $workdir/latitude > $workdir/lonlat
log $? "Join lon lat file"

#extract timesteps
timesteps=$(cdo showtimestamp $fluxfile)
log $? "STEP 3: Extract timestamp"

# 2) foreach variable
for var in $variables; do
	# 3) foreach timestep
	tindex=0	
	for curtimestep in $timesteps; do
		log "notice" "TODO3 : regrid data for var ${var} and timestep ${curtimestep}"
		# trick to print on three digits and avoid time gaps while ncrcatting
		curtimestep3d=$(printf "%03d" $tindex)

		ncks -v $var -d time,$tindex inputs/gmtcompliant/ARPERACUR-201201.nc | sed '1,20d' | sed '/^$/d' | awk 'BEGIN {FS = "="} ;{print $3}' | awk '{print $1}' | sed '/^$/d' > $workdir/current_flux
		
		paste $workdir/lonlat $workdir/current_flux > $workdir/$var-$curtimestep3d.xyz

		#interpolation
		gmt nearneighbor $workdir/$var-$curtimestep3d.xyz $envelope -I${Xinc}/${Yinc} $paramN $paramS -G$workdir/$var-$curtimestep3d.grd
		rm $workdir/$var-$curtimestep3d.xyz

		# refractor output file
		ncrename -h -v lon,longitude -v lat,latitude -v z,$var $workdir/$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,longitude,d,f," " $workdir/$var-$curtimestep3d.grd
		ncatted -h -a long_name,longitude,c,c,"longitude"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a units,longitude,c,c,"degrees_east"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a axis,longitude,c,c,"X"  $workdir/$var-$curtimestep3d.grd

		ncatted -h -O -a long_name,latitude,d,f," " $workdir/$var-$curtimestep3d.grd
		ncatted -h -a long_name,latitude,c,c,"latitude"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a units,latitude,c,c,"degrees_north"  $workdir/$var-$curtimestep3d.grd
		ncatted -h -a axis,latitude,c,c,"Y"  $workdir/$var-$curtimestep3d.grd
		
		ncrename -h -d lon,longitude -d lat,latitude $workdir/$var-$curtimestep3d.grd
		
		#add variable time and set time with current time step
		hour=$((($tindex + 1)*6))
		ncap -h -O -s "time=$hour" $workdir/$var-$curtimestep3d.grd $workdir/$var-$curtimestep3d.grd
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
	log "notice" "STEP4: concat timestep for variable ${var}"
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
rm $work/lonlat

#5) finally join variables
log "notice" "STEP5 : join all freshly concatened files for each variables into one"
for ncfile in $workdir/*.nc ; do
	mkdir -p $outdir/$year/$month
	ncks -A $ncfile $outdir/$year/$month/$outfile
done

log "notice" "STEP6 : clean"
rm $workdir/*.grd