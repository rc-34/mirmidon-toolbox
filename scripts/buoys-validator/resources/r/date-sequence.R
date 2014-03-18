args<-commandArgs(trailingOnly=TRUE)
d<-seq(from = as.POSIXct(args[1]), length.out=as.numeric(args[2]), 
       by = "hour")
write.csv(d,file=args[3],row.names=FALSE, na="")
