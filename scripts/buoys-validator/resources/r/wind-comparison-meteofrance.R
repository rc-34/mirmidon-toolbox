require(ggplot2)
require(reshape2)
has2print=FALSE

buoy<-"MeteoFrance"
year<-"2012"
start<-"2012-01-01 18:00:00"
end<-"2012-01-31 00:00:00"

#Declare Stations
stations=c("MeteoFranc")

#For each stations
for(station in stations) {
  #MODEL PART
  modeldf<-read.csv(paste("../../outputs/",station,"-wnd.csv",sep=""),header=TRUE,col.names=c("date","wnd"))
  modeldf['date']<-as.POSIXct(modeldf$date,tz="Etc/GMT+12",format='%Y-%m-%d %H:%M:%S')
  modeldf['wnd']<-as.numeric(modeldf$wnd)
  modeldf['wnd']<-as.numeric(modeldf$wnd)*3.6 #convert to km/h
  
  #MEASURE PART
  #SOLTC SRC
  measuredf.full<-read.csv(paste(paste("../../inputs/soltc/",station,sep=""),".csv",sep=""),header=TRUE,col.names=c("id","date","temp","temp_pt_rosee","sea_pressure","wnd","wnd_dir","gust","humidity","tension_vap","sst","hs","tmoy","consolidated","quai"))
#   measuredf.full['date']<-as.POSIXct(measuredf.full$date,tz="Etc/GMT-12",format='%Y-%m-%d %H:%M:%S')
  measuredf.full['date']<-as.POSIXct(measuredf.full$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
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
  
  measuredf<-data.frame(date=measuredf.full$date,wnd=measuredf.full$wnd)
  
  #MERGE dfs
  df.mix<-merge(modeldf,measuredf,by='date',all.x=TRUE,suffixes=c(".ww3",".buoy"))
  df.mix<-df.mix[df.mix$date > as.POSIXct(start,tz="GMT") & df.mix$date < as.POSIXct(end,tz="GMT"),]

  #ARPERA PART
  if (year %in% "2012") {
    arperadf<-read.csv("../../outputs/arpera-wnd.csv",header=TRUE,col.names=c("date","wnd"))
    arperadf['date']<-as.POSIXct(arperadf$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    arperadf['wnd']<-as.numeric(arperadf$wnd)
    arperadf['wnd']<-as.numeric(arperadf$wnd)*3.6 #convert to km/h
    arperadf<-arperadf[arperadf$date > as.POSIXct(start,tz="UTC") & arperadf$date < as.POSIXct(end,tz="UTC"),]
    
    #PLOT
    pline<-ggplot(df.mix, aes(date)) + 
      geom_line(data=arperadf,aes(x=date,y = wnd,colour="arpera"),alpha=1,size=0.7,linetype="dashed")+
      geom_line(aes(y = wnd.buoy,colour="buoy"),alpha=1,size=0.5)+
      geom_line(aes(y = wnd.ww3,colour="ww3"),alpha=1/2,size=0.5)+
      scale_colour_manual("", breaks = c("arpera","buoy", "ww3"),
                          values = c("green","lightgrey", "blue")) +
      theme(panel.background = element_rect(fill="white"))+
      ylab("WND (Km/H)") +
      xlab(paste("Time (Year ",year,")",sep=""))+
      theme_bw() +
      theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
      theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
      theme(text = element_text(size=20))+
      ylim(c(0,120))+
      labs(title=paste("Validation - ",buoy,sep=""))
    
#     ppoint<-ggplot(df.mix, aes(date)) + 
#       theme(panel.background = element_rect(fill="white"))+
#       geom_line(aes(y = wnd.arpera,colour="arpera"),alpha=1/2,size=0.5)+
#       geom_point(aes(y = wnd.buoy, colour = "buoy"),alpha=1,size=2) +
#       geom_point(aes(y = wnd.ww3, colour = "ww3"),alpha=1/2,size=2) + 
#       scale_colour_manual("", breaks = c("arpera","buoy", "ww3"),
#                           values = c("green","lightgrey", "blue")) +
#       ylab("Hs (m)") +
#       theme_bw() +
#       theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#       theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#       theme(text = element_text(size=20))+
#       labs(title=paste("Validation - ",buoy,sep=""))+
#       xlab(paste("Time (Year ",year,")",sep=""))
#     
#     #QQPLOT
#     d<- as.data.frame(qqplot(df.mix$wnd.ww3, df.mix$wnd.buoy, plot.it=FALSE))
#     colnames(d)[1]<-'ww3'
#     colnames(d)[2]<-'buoy'
#     qqp<- ggplot(d) + 
#       theme(panel.background = element_rect(fill="white"))+
#       geom_point(aes(x=sort(d$ww3), y=sort(d$buoy))) +
#       geom_abline(slope=1,aes(colour="line")) +
#       xlab("Model WW3 WND(Km/H)") + 
#       ylab("Buoy WND(Km/H)") +
#       theme_bw() +
#       theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#       theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#       theme(text = element_text(size=20))+
#       labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))
#     
#     d<- as.data.frame(qqplot(df.mix$wnd.arpera, df.mix$wnd.buoy, plot.it=FALSE))
#     colnames(d)[1]<-'arpera'
#     colnames(d)[2]<-'buoy'
#     qqp2<- ggplot(d) + 
#       theme(panel.background = element_rect(fill="white"))+
#       geom_point(aes(x=sort(d$arpera), y=sort(d$buoy))) +
#       geom_abline(slope=1,aes(colour="line")) +
#       xlab("Reanalysis ARPERA WND(Km/H)") + 
#       ylab("Buoy WND(Km/H)") +
#       theme_bw() +
#       theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#       theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#       theme(text = element_text(size=20))+
#       labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))
#     
#     d<- as.data.frame(qqplot(df.mix$wnd.arpera, df.mix$wnd.ww3, plot.it=FALSE))
#     colnames(d)[1]<-'arpera'
#     colnames(d)[2]<-'ww3'
#     qqp<- ggplot(d) + 
#       theme(panel.background = element_rect(fill="white"))+
#       geom_point(aes(x=sort(d$ww3), y=sort(d$buoy))) +
#       geom_abline(slope=1,aes(colour="line")) +
#       ylab("Model WW3 WND(Km/H)") + 
#       xlab("Reanalysis ARPERA WND(Km/H)") +
#       theme_bw() +
#       theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#       theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#       theme(text = element_text(size=20))+
#       labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))
    
  } else {
    #MERGE dfs
    df.mix<-merge(modeldf,measuredf,by='date',all.x=TRUE,suffixes=c(".ww3",".buoy"))
    df.mix<-df.mix[df.mix$date > as.POSIXct(start,tz="GMT") & df.mix$date < as.POSIXct(end,tz="GMT"),]
    
    #PLOT
    pline<-ggplot(df.mix, aes(date)) + 
      geom_line(aes(y = wnd.buoy,colour="buoy"),alpha=1,size=0.5)+
      geom_line(aes(y = wnd.ww3,colour="ww3"),alpha=1/2,size=0.5)+
      scale_colour_manual("", breaks = c("buoy", "ww3"),
                          values = c("lightgrey", "blue")) +
      theme(panel.background = element_rect(fill="white"))+
      ylab("WND (Km/H)") +
      xlab(paste("Time (Year ",year,")",sep=""))+
      theme_bw() +
      theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
      theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
      theme(text = element_text(size=20))+
      ylim(c(0,120))+
      labs(title=paste("Validation - ",buoy,sep=""))
    if (has2print) {
      ggsave(paste("~/Desktop/",year,"-pline-",station,".png",sep=""),width=8,height=6)
    }
    
    ppoint<-ggplot(df.mix, aes(date)) + 
      theme(panel.background = element_rect(fill="white"))+
      geom_point(aes(y = wnd.buoy, colour = "buoy"),alpha=1,size=2) +
      geom_point(aes(y = wnd.ww3, colour = "ww3"),alpha=1/2,size=2) + 
      scale_colour_manual("", breaks = c("buoy", "ww3"),
                          values = c("lightgrey", "blue")) +
      ylab("Hs (m)") +
      theme_bw() +
      theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
      theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
      theme(text = element_text(size=20))+
      labs(title=paste("Validation - ",buoy,sep=""))+
      xlab(paste("Time (Year ",year,")",sep=""))
    if (has2print) {
      ggsave(paste("~/Desktop/",year,"-ppoint-",station,".png",sep=""),width=8,height=6)
    }
    
    #QQPLOT
    d<- as.data.frame(qqplot(df.mix$wnd.ww3, df.mix$wnd.buoy, plot.it=FALSE))
    colnames(d)[1]<-'ww3'
    colnames(d)[2]<-'buoy'
    qqp<- ggplot(d) + 
      theme(panel.background = element_rect(fill="white"))+
      geom_point(aes(x=sort(d$ww3), y=sort(d$buoy))) +
      geom_abline(slope=1,aes(colour="line")) +
      xlab("Model WW3 WND(Km/H)") + 
      ylab("Buoy WND(Km/H)") +
      theme_bw() +
      theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
      theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
      theme(text = element_text(size=20))+
      labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))
    if (has2print) {
      ggsave(paste("~/Desktop/",year,"-qqpoint-",station,".png",sep=""),width=8,height=6)
    }
    
  }

  #d<-data.frame(modeled=df.mix$hs.modeled, observed=df.mix$hs.measured)
  #qqp<-ggplot(d,aes(sample=d$observed))+stat_qq()
  
#   #SCATTERPLOT
#   d<-data.frame(modeled=df.mix$hs.modeled, observed=df.mix$hs.measured)
#   sp <- ggplot(d, aes(x=d$modeled, y=d$observed)) +
#     theme(panel.background = element_rect(fill="white"))+
#     geom_point(shape=1) +    # Use hollow circles
#     xlab("model") + 
#     ylab("observation") +
#     #geom_smooth(method=lm)
#     geom_smooth()            # Add a loess smoothed fit curve with confidence region
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-scatter-",station,".png",sep=""),width=8,height=6)
#   }
}