library(RNetCDF)

ww3nctab2df <- function (file,station=NULL){
  
  nc.file<-open.nc(file)
  nc<-read.nc(nc.file)
  
  #refractor into a df
  df<-data.frame(date=nc$time,hs.espi=nc$hs[1,]
                       ,hs.sete=nc$hs[2,]
                       ,hs.leucate=nc$hs[3,]
                       ,hs.banyuls=nc$hs[4,]
                       ,hs.meteofranc=nc$hs[5,])
  
  t<-seq(from = as.POSIXct("2011-01-01",tz="GMT"), length.out=length(nc$time), 
      by = "hour")
  df$date<-t
  
  return(df)
}