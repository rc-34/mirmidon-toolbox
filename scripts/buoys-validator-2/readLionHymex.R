readLionHymex <- function(year,hymexdir) {
  measuredf<-read.csv(paste(hymexdir,"/Lion_HS_",year,".dat",sep=""),sep=";",header=TRUE,col.names=c("date","hs"))
  measuredf['date']<-as.POSIXct(measuredf$date,tz="GMT",format='%Y-%m-%d %H:%M:%S')
  
  return (measuredf)
}