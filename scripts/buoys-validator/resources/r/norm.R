args<-commandArgs(trailingOnly=TRUE)
infile<-as.character(args[1])
outfile<-as.character(args[2])

data<-read.csv(infile,header=FALSE,sep="\t")

data$V3 <- sqrt(as.numeric(as.character(data$V1))^2 + as.numeric(as.character(data$V2))^2)

obj<-as.vector(data$V3)


write.table(obj,file = outfile,col.names=FALSE,row.names=FALSE)

mpi.quit()