#!/bin/bash
# # @ account_no = mirmidon
# # @ class = intel
# # @ job_type = serial
# # @ wall_clock_limit = 03:00:00,2:50:00
# # @ environment = COPY_ALL
# # @ queue

# ###ENV###
#export WORKINGDIR=/scratch/chailanr/mirmidon-toolbox/scripts/megagol-autorun
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/lib:/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH
#export PATH=/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/bin:$PATH

# cd $WORKINGDIR

#source utilities
source ./resources/sh/utility.sh
source ./resources/sh/reformat.sh

rightnow
log "notice" "STARTING... $d"

if [ $# -ne 2 ]
then
	log "warning" "Usage: ./ug2reg.cmd BEGINNINGYEAR ENDYEAR"
	log "warning" "Exemple: ./ug2reg.cmd 1961 2012"
	log -1
fi
beginningyear=$1
endyear=$2
interpoldir="resources/interpolresources"
regoutputsdir="outputs/ounfREG"
finidir="fini"

if [ ! -d $regoutputsdir ];
	then
	mkdir -p $regoutputsdir
fi

sequence=$(seq $beginningyear $endyear)
log $? "Sequence : determined."

for year in $sequence ; do
	workdir=$finidir/$year
	cd $workdir
	log $? "Change to $year directory"

	cp ../../$interpoldir/ww3_gint.inp .
	cp ../../$interpoldir/ww3_grid.inp.ug .
	cp ../../$interpoldir/ww3_grid.inp.reg .
	cp ../../$interpoldir/ww3_ounf.inp.reg .
	cp ../../$interpoldir/ww3_ounf.inp.ug .
	cp ../../$interpoldir/bathy_ww3_wmed.txt .

	formatinpInterpol ./ $year
	log $? "Format date in .inp files"

	rm mod_def*
	ln -sf ww3_grid.inp.ug ww3_grid.inp
	../../$interpoldir/ww3_grid > grid.out.ug
	log $? "Re-process ug grid with updated ww3_grid binary"
	mv mod_def.ww3  mod_def.ug

	ln -sf ww3_grid.inp.reg ww3_grid.inp
	../../$interpoldir/ww3_grid > grid.out.reg
	log $? "Process reg grid with updated ww3_grid binary"
	mv mod_def.ww3 mod_def.reg

	ln -sf mod_def.ug  mod_def.ww3
	#qsub -N shel job_shel.pbs
	mv out_grd.ww3  out_grd.ug
	log $? "Move grd.ww3 file to grd.ug"

	../../$interpoldir/ww3_gint > grid.out.interpolate
	log $? "Interpolation to reg grid"

	ln -sf ww3_ounf.inp.reg ww3_ounf.inp
	ln -sf mod_def.reg mod_def.ww3
	ln -sf out_grd.reg out_grd.ww3
	../../$interpoldir/ww3_ounf
	log $? "ww3_ounf processing for reg grid"

	mv GOLREG*.nc ../../$regoutputsdir/.
	log $? "Move interpolated nc files"

	ln -sf ww3_ounf.inp.ug ww3_ounf.inp
	ln -sf mod_def.ug mod_def.ww3
	ln -sf out_grd.ug out_grd.ww3
	log $? "Switch back inp and ww3 files"
	#./ww3_ounf

	cd ../..
	log $? "Go back to root directory"
done