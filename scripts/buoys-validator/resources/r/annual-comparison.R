library(ggplot2)

has2print=FALSE
#has2print=TRUE

#Declare Stations
#stations=c("Espiguette","Leucate","Banyuls","Sete")
#stations=c("Banyuls")
#stations=c("Banyuls")
#stations=c("Espiguette")
stations=c("Sete")

#For each stations
for(station in stations) {
  #MODEL PART
  #modeldf<-read.csv(paste(paste("../../outputs/",station,sep=""),"-hs.csv",sep=""),header=TRUE)
  #modeldf['date']<-as.POSIXct(modeldf$date,tz="GMT",format='%Y-%m-%d %H:%M:%S')
  #modeldf['hs']<-as.numeric(modeldf$hs)
  
  ##POUR L ANNEE 2011 SEULEMENT
  modeldf<-ww3nctab2df("../../inputs/model/OUNP-MEDNORD-2010_tab.nc")
  modeldf<-data.frame(date=modeldf$date,hs=modeldf$hs.sete)
  
  #MEASURE PART
  measuredf<-read.csv(paste(paste("../../inputs/soltc/",station,sep=""),"_H1_3.csv",sep=""),header=TRUE,col.names=c("date","hs"))
  measuredf['date']<-gsub("\t","",measuredf[,'date'])
  measuredf['date']<-as.POSIXct(measuredf$date,tz="GMT",format='%Y-%m-%d %H:%M:%S')
  measuredf['hs']<-as.numeric(measuredf$hs)

  newdate=c(measuredf$date[1])
  newhs=c(measuredf$hs[1])
  i=3
  while (i <= nrow(measuredf)) {
    newdate=c(newdate,measuredf$date[i])
    newhs=c(newhs,(measuredf$hs[i]+measuredf$hs[i-1]) / 2)
    i=i+2
  }
  measuredf<-data.frame(date=newdate,hs=newhs)
  
  #MERGE dfs
  df.mix<-merge(modeldf,measuredf,by='date',suffixes=c(".modeled",".measured"))
  df.mix<-df.mix[df.mix$date > as.POSIXct("2011-10-01 00:00:00",tz="GMT") & df.mix$date < as.POSIXct("2012-01-01 00:00:00",tz="GMT"),]
  
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