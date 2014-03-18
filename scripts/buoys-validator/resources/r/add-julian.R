args<-commandArgs(trailingOnly=TRUE)
N<-as.numeric(args[1])
y<-(N%/%365.2425)
YYYY<-y+1
print(YYYY)