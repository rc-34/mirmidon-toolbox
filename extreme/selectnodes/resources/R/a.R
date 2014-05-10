args<-commandArgs(trailingOnly=TRUE)

zmax<-as.numeric(args[1])
k<-as.numeric(args[2])
a<-zmax/exp(k)

for (i in 1:k) {
  print(a*exp(i))
}