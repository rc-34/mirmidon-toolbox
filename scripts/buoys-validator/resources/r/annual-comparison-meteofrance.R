library(ggplot2)
library(reshape2)
source(file="ww3nctab2df.R")
has2print=FALSE
#has2print=TRUE

#Declare Stations
stations=c("MeteoFranc")

#For each stations
for(station in stations) {
  #MODEL PART
  #modeldf<-read.csv(paste(paste("../../outputs/",station,sep=""),"-hs.csv",sep=""),header=TRUE)
  modeldf<-ww3nctab2df("../../inputs/model/OUNP-MEDNORD-2010_tab.nc")
  #modeldf['date']<-as.POSIXct(modeldf$date,tz="GMT",format='%Y-%m-%d %H:%M:%S')
  #modeldf['hs']<-as.numeric(modeldf$hs)
  
  modeldf<-data.frame(date=modeldf$date,hs=modeldf$hs.meteofranc)
  
  #MEASURE PART
  measuredf.full<-read.csv(paste(paste("../../inputs/soltc/",station,sep=""),".csv",sep=""),header=TRUE,col.names=c("id","date","temp","temp_pt_rosee","sea_pressure","wnd","wnd_dir","gust","humidity","tension_vap","sst","hs","tmoy","consolidated","quai"))
  measuredf.full['date']<-as.POSIXct(measuredf.full$date,tz="Etc/GMT-12",format='%Y-%m-%d %H:%M:%S')
  measuredf.full['temp']<-as.numeric(as.character(measuredf.full$temp))
  measuredf.full['temp_pt_rosee']<-as.numeric(as.character(measuredf.full$temp_pt_rosee))
  measuredf.full['sea_pressure']<-as.numeric(as.character(measuredf.full$sea_pressure))
  measuredf.full['wnd']<-as.numeric(as.character(measuredf.full$wnd))
  measuredf.full['wnd_dir']<-as.numeric(as.character(measuredf.full$wnd_dir))
  measuredf.full['gust']<-as.character(measuredf.full$gust)
  measuredf.full['humidity']<-as.numeric(as.character(measuredf.full$humidity))
  measuredf.full['tension_vap']<-as.numeric(as.character(measuredf.full$tension_vap))
  measuredf.full['sst']<-as.numeric(as.character(measuredf.full$sst))
  measuredf.full['hs']<-as.numeric(as.character(measuredf.full$hs))
  measuredf.full['tmoy']<-as.numeric(as.character(measuredf.full$tmoy))
  measuredf.full['consolidated']<-as.character(measuredf.full$consolidated)
  
  measuredf<-data.frame(date=measuredf.full$date,hs=measuredf.full$hs)
  #measuredf<-measuredf[measuredf$date > as.POSIXct("2011-10-01 00:00:00",tz="GMT") & measuredf$date < as.POSIXct("2011-10-10 00:00:00",tz="GMT"),]
  
  #MERGE dfs
  df.mix<-merge(modeldf,measuredf,by='date',suffixes=c(".modeled",".measured"))
  
  df.mix<-df.mix[df.mix$date > as.POSIXct("2011-12-01 00:00:00",tz="GMT") & df.mix$date < as.POSIXct("2012-01-01 00:00:00",tz="GMT"),]
  
  
  #PLOT
  pline<-ggplot(df.mix, aes(date)) + 
    geom_line(aes(y = hs.modeled, colour = "modeled")) + 
    geom_line(aes(y = hs.measured, colour = "observed")) +
    theme(axis.title.x = element_blank()) +
    ylab("Hs (m)") +
    labs(colour = paste("Station",station,sep=": "))
  if (has2print) {
    ggsave(paste(paste("~/Desktop/2011-pline-",station,sep=""),".png",sep=""),width=8,height=6)
  }
  
  ppoint<-ggplot(df.mix, aes(date)) + 
    geom_point(aes(y = hs.modeled, colour = "modeled"),alpha=1/2,size=2) + 
    geom_point(aes(y = hs.measured, colour = "observed"),alpha=1/2,size=2) +
    theme(axis.title.x = element_blank()) +
    ylab("Hs (m)") +
    labs(colour = paste("Station",station,sep=": "))
  if (has2print) {
    ggsave(paste(paste("~/Desktop/2011-ppoint-",station,sep=""),".png",sep=""),width=8,height=6)
  }
  
  #QQPLOT
  d<- as.data.frame(qqplot(df.mix$hs.modeled, df.mix$hs.measured, plot.it=FALSE))
  #d<- rename(d, c("x"="modeled", "y"="observed"))
  colnames(d)[1]<-'modeled'
  colnames(d)[1]<-'observed'
  qqp<- ggplot(d) + 
    geom_point(aes(x=d$modeled, y=d$observed)) +
    geom_abline(slope=1,aes(colour="line")) +
    xlab("model") + 
    ylab("observation")
  if (has2print) {
    ggsave(paste(paste("~/Desktop/2011-qqp-",station,sep=""),".png",sep=""),width=8,height=6)
  }
  
  #d<-data.frame(modeled=df.mix$hs.modeled, observed=df.mix$hs.measured)
  #qqp<-ggplot(d,aes(sample=d$observed))+stat_qq()
  
  #SCATTERPLOT
  d<-data.frame(modeled=df.mix$hs.modeled, observed=df.mix$hs.measured)
  sp <- ggplot(d, aes(x=d$modeled, y=d$observed)) +
    geom_point(shape=1) +    # Use hollow circles
    xlab("model") + 
    ylab("observation") +
    #geom_smooth(method=lm)
    geom_smooth()            # Add a loess smoothed fit curve with confidence region
  if (has2print) {
    ggsave(paste(paste("~/Desktop/2011-scatter-",station,sep=""),".png",sep=""),width=8,height=6)
  }
}