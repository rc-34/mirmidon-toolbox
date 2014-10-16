args<-commandArgs(trailingOnly=TRUE)
d<-seq(from = as.POSIXct(paste(args[1],args[2]),tz="GMT"), length.out=as.numeric(args[2]), 
       by = "6 hours")


write.table(d,file=as.character(args[4]),row.names=FALSE, col.names=FALSE)

mpi.quit()