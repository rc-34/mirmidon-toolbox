#!/bin/sh

# @ account_no = mirmidon
# @ class = intel
# @ job_type = serial
# @ wall_clock_limit = 03:00:00,2:50:00
# @ environment = COPY_ALL
# @ queue

exec 2>job.err 1>job.out

###ENV###
export WORKINGDIR=path-to-working-dir
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH
echo 'PREPROCESSING...'
echo 'Change directory to $WORKINGDIR'

cd $WORKINGDIR

echo 'Grid pre-processing...'
./ww3_grid
echo 'Restart pre-processing...'
./ww3_strt
echo 'Inputs fluxes pre-processing...'
./prnc.sh
