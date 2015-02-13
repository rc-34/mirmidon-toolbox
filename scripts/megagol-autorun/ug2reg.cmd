#!/bin/sh                                                                                                                                                                       
# @ account_no = mirmidon
# @ class = intel
# @ job_type = serial
# @ wall_clock_limit = 72:00:00,71:50:00
# @ environment = COPY_ALL
# @ node_usage = not_shared
# @ queue

###ENV###
source /opt/cluster/softs/gcc-4.6.x-soft/system/module/3.2.10/Modules/3.2.10/init/sh
module purge
module load hpclr-wrapper intel-13.0.1 openmpi-1.6.5-intel

export WORKINGDIR=/gpfs2/scratch/chailanr/interpolator/mirmidon-toolbox/scripts/megagol-autorun	
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH

echo 'POSTPROCESSING...'
echo 'Change directory to $WORKINGDIR'

cd $WORKINGDIR

#source utilities
source ./resources/sh/utility.sh
source ./resources/sh/reformat.sh

rightnow
log "notice" "STARTING-interpol... $d"

# if [ $# -ne 2 ]
# then
# 	log "warning" "Usage: ./ug2reg.cmd BEGINNINGYEAR ENDYEAR"
# 	log "warning" "Exemple: ./ug2reg.cmd 1961 2012"
# 	log -1
# fi
beginningyear=2008
endyear=2012
interpoldir="resources/interpolresources"
regoutputsdir="outputs/ounf/REG"
megagoloutputsdir="/gpfs2/scratch/chailanr/mirmidon-toolbox/scripts/megagol-autorun/work"
work="workREG"

if [ ! -d $regoutputsdir ];
	then
	mkdir -p $regoutputsdir
fi

sequence=$(seq $beginningyear $endyear)
log $? "Sequence : determined."

for year in $sequence ; do
	workdir=$work/$year
	if [ ! -d $workdir ]; 
		then
		mkdir -p $workdir
	fi
	cd $workdir
	log $? "Change to $workdir directory"

	cp ../../$interpoldir/ww3_gint.inp .
	cp ../../$interpoldir/ww3_grid.inp.ug .
	cp ../../$interpoldir/ww3_grid.inp.reg .
	cp ../../$interpoldir/ww3_ounf.inp.reg .
	cp ../../$interpoldir/ww3_ounf.inp.ug .
	cp ../../$interpoldir/big.xy .
	cp ../../$interpoldir/ww3_grid . 
	cp ../../$interpoldir/ww3_ounf . 
	log $? "cp files from $interpoldir"

	cp $megagoloutputsdir/$year/mesh.msh .
	log $? "cp files from $megagoloutputsdir/$year"	

	formatinpInterpol ./ $year
	log $? "Format date in .inp files"

	rm mod_def*
	ln -sf ww3_grid.inp.ug ww3_grid.inp
	./ww3_grid > grid.out.ug
	log $? "Re-process ug grid with updated ww3_grid binary"
	mv mod_def.ww3 mod_def.ug

	ln -sf ww3_grid.inp.reg ww3_grid.inp
	./ww3_grid > grid.out.reg
	log $? "Process reg grid with updated ww3_grid binary"
	mv mod_def.ww3 mod_def.reg

	ln -sf mod_def.ug  mod_def.ww3
	ln -s $megagoloutputsdir/$year/out_grd.ww3 out_grd.ug
	log $? "link out_grd.ww3.ug"
	rightnow
	log "notice" "$d"

	cp ../../$interpoldir/ww3_gint .
	./ww3_gint &> grid.out.interpolate 
	log $? "Interpolation to reg grid"
	rightnow
	log "notice" "$d"

	ln -sf ww3_ounf.inp.reg ww3_ounf.inp
	ln -sf mod_def.reg mod_def.ww3
	ln -sf out_grd.reg out_grd.ww3
	../../$interpoldir/ww3_ounf
	log $? "ww3_ounf processing for reg grid"
	rightnow
	log "notice" "$d"

	mv MEGAGOL2015a-REG-big-OUNF*.nc ../../$regoutputsdir/.
	log $? "Move interpolated nc files"

	ln -sf ww3_ounf.inp.ug ww3_ounf.inp
	ln -sf mod_def.ug mod_def.ww3
	ln -sf out_grd.ug out_grd.ww3
	log $? "Switch back inp and ww3 files"

	cd ../..
	log $? "Go back to root directory"
done
rightnow
log $? "That's all folks! -- $d -- "