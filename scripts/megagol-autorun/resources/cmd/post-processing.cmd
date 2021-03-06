#!/bin/sh                                                                                                                                                                       
# @ account_no = mirmidon
# @ class = intel
# @ job_type = serial
# @ wall_clock_limit = 10:00:00,9:50:00
# @ environment = COPY_ALL
# @ queue

###ENV###
export WORKINGDIR=pathtoworkingdir	
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/lib:/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH
export PATH=/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/bin:$PATH
echo 'POSTPROCESSING...'
echo 'Change directory to $WORKINGDIR'

cd $WORKINGDIR

echo "WW3_OUNP post-processing..."
./ww3_ounp
echo "WW3_OUNF post-processing..."
./ww3_ounf