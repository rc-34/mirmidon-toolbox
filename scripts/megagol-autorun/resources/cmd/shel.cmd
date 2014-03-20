#!/bin/sh                                                                                                                                                                       
# @ account_no = mirmidon
# @ class = intel
# @ job_type = mpich
# @ initialdir = pathtoworkingdir
# @ node = 28
# @ node_usage = not_shared
# @ total_tasks = 196
# @ wall_clock_limit = 20:00:00,20:00:00
# @ environment = COPY_ALL
# @ queue

exec 2>job.err 1>job.out

###ENV###
##intel 13.1 and openmpi 1.6.5##
source /opt/cluster/softs/gcc-4.6.x-soft/system/module/3.2.10/Modules/3.2.10/init/sh
module purge
module load hpclr-wrapper intel-13.0.1 openmpi-1.6.5-intel


###MPI###
#export I_MPI_FABRICS=shm:tmi 

###Others###
export WORKINGDIR=pathtoworkingdir
export PERNODE=7
export WWATCH3_NETCDF=NC4
export NETCDF_CONFIG=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/bin/nc-config
export LD_LIBRARY_PATH=/work/mirmidon/softs/intel-13.x-soft/io/netcdf/netcdf-fortran-4.1.3/lib:$LD_LIBRARY_PATH

cat $LOADL_HOSTFILE > hostfile 

#ompi run#
/opt/cluster/softs/intel-13.x-soft/system/openmpi/1.6.5/bin/./mpirun  -x LD_LIBRARY_PATH -npernode $PERNODE -display-map -np $LOADL_TOTAL_TASKS -machinefile $LOADL_HOSTFILE  $WORKINGDIR/ww3_shel