library(geosphere)
library(sp)

args<-commandArgs(trailingOnly=TRUE)

#collect arguments
nodefilepath<-args[1]
refpoint.lon<-as.numeric(args[2])
refpoint.lat<-as.numeric(args[3])
refpoint<-c(refpoint.lon,refpoint.lat)

f<-read.csv(file=nodefilepath,sep="\t",header=FALSE)
#V1 = lon
#V2 = lat
#for each point in nodefile, compute the distance. 
#if it < then keep that node. otherwise go to the next point, till there is no point remaining
closestpoint.lon<-f$V1[1]
closestpoint.lat<-f$V2[1]
closestpoint.node<-f$V4[1]
closestpoint<-c(closestpoint.lon,closestpoint.lat)
distance<-distm(refpoint,closestpoint)
for (i in 2:length(f$V1)) {
  challengepoint.lon<-f$V1[i]
  challengepoint.lat<-f$V2[i]
  challengepoint.node<-f$V4[i]
  challengepoint<-c(challengepoint.lon,challengepoint.lat)
  if (distm(refpoint,challengepoint) < distance) {
    distance <- distm(refpoint,challengepoint)
    closestpoint.lon<-f$V1[i]
    closestpoint.lat<-f$V2[i]
    closestpoint.node<-f$V4[i]
    closestpoint<-c(closestpoint.lon,closestpoint.lat)
  }
}
sprintf("%s %s %s",closestpoint.lon,closestpoint.lat,closestpoint.node)