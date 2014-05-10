library(lhs)
library(DiceDesign)

args<-commandArgs(trailingOnly=TRUE)

nbrpoint<-as.numeric(args[1])
xmin<-as.numeric(args[2])
xmax<-as.numeric(args[3])
ymin<-as.numeric(args[4])
ymax<-as.numeric(args[5])


lhs<-randomLHS(n=nbrpoint,k=2)
maximinlhs<-maximinSA_LHS(lhs)

lon<-(maximinlhs$design[,1]*(xmax-xmin)+xmin)
lat<-(maximinlhs$design[,2]*(ymax-ymin)+ymin)

coord<-cbind(lon,lat)

print(coord)
