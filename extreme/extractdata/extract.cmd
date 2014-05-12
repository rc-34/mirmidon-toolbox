#!/bin/sh

# @ account_no = mirmidon
# @ class = intel
# @ job_type = serial
# @ wall_clock_limit = 2:30:00,2:30:00
# @ environment = COPY_ALL
# @ queue

exec 2>job.err 1>job.out

###ENV###
export WORKINGDIR=/scratch/chailanr/mirmidon-toolbox/extreme/extractdata
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/lib:/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH
export PATH=/work/mirmidon/softs/intel-13.x-soft/io/cdo/1.6.3/bin:/work/mirmidon/softs/intel-13.x-soft/io/nco/nco-4.4.2/bin:$PATH


./extract.sh