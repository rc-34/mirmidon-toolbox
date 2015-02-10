library(RNetCDF)

file="../../inputs/MEDNORD-201111.nc"
nc.file<-open.nc(file)
nc<-read.nc(nc.file)
