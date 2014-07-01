require(ggplot2)
require(reshape2)


year<-"2011"
start<-"2011-09-01 00:00:00"
#start<-"2011-01-01 00:00:00"
end<-"2011-12-31 23:00:00"
#end<-"2011-09-20 23:00:00"

stations=c("Espiguette")
file="CANDHIS_export_pem_03001_Base"
stations=c("Sete")
file="CANDHIS_export_pem_03404_Base"
stations=c("Leucate")
file="CANDHIS_export_pem_01101_Base"
stations=c("Banyuls")
file="CANDHIS_export_pem_06601_Base"
# stations=c("CAMARGUE")
# file="CANDHIS_export_pem_01301_Base"
# stations=c("MARSEILLE")
# file="CANDHIS_export_pem_01304_Base"
# stations=c("TOULON")
# file="CANDHIS_export_pem_08301_Base"

#For each stations
for(station in stations) {
  #MODEL PART
  #HS
  modeldf.hs<-read.csv(paste("../../outputs/",station,"-hs.csv",sep=""),header=TRUE,col.names=c("date","hs"))
  modeldf.hs['date']<-as.POSIXct(modeldf.hs$date,tz="Etc/GMT+12",format='%Y-%m-%d %H:%M:%S')
  modeldf.hs['hs']<-as.numeric(modeldf.hs$hs)
  #fp - dominant wave frequency
  modeldf.fp<-read.csv(paste("../../outputs/",station,"-fp.csv",sep=""),header=TRUE,col.names=c("date","fp"))
  modeldf.fp['date']<-as.POSIXct(modeldf.fp$date,tz="Etc/GMT+12",format='%Y-%m-%d %H:%M:%S')
  modeldf.fp['period']<-1/as.numeric(modeldf.fp$fp)
  modeldf.fp <- subset(modeldf.fp, select = -c(fp) )
  #th1m - mean wave direction
  modeldf.th1m<-read.csv(paste("../../outputs/",station,"-dir.csv",sep=""),header=TRUE,col.names=c("date","th1m"))
  modeldf.th1m['date']<-as.POSIXct(modeldf.th1m$date,tz="Etc/GMT+12",format='%Y-%m-%d %H:%M:%S')
  modeldf.th1m['th1m']<-as.numeric(modeldf.th1m$th1m)
  #th1p - dominant wave direction
  modeldf.th1p<-read.csv(paste("../../outputs/",station,"-dirpeak.csv",sep=""),header=TRUE,col.names=c("date","th1p"))
  modeldf.th1p['date']<-as.POSIXct(modeldf.th1p$date,tz="Etc/GMT+12",format='%Y-%m-%d %H:%M:%S')
  modeldf.th1p['th1p']<-as.numeric(modeldf.th1p$th1p)
  modeldf<-merge(modeldf.hs,
                 merge(modeldf.fp,
                       merge(modeldf.th1p,
                             modeldf.th1m)))
  modeldf<-modeldf[modeldf$date >= as.POSIXct(start,tz="GMT") & modeldf$date <= as.POSIXct(end,tz="GMT") ,]
  df.mod<-melt(modeldf,id=1)
  df.mod['Source']<-"Model"
  
 
  #MEASURES/OBSERVATION PART
  measuredf<-read.csv(paste("../../inputs/candhis//donnees_candhis_cerema/",file,".csv",sep=""),sep=";",header=TRUE)
  measuredf$dateheure<-as.POSIXct(measuredf$dateheure,tz="GMT",format='%Y-%m-%d %H:%M:%S')
  if(is.null(measuredf$hm0[1])) {hsignificant <- measuredf$h13d; print("Warning: Hm0 not available")} else {hsignificant <- measuredf$hm0}
  measuredf<-data.frame(date=measuredf$dateheure,
                        hs=hsignificant,#non spectral mais pas disponible
                        period=measuredf$tp,#periode moyenne
                        th1p=measuredf$thetap,#dir pic
                        th1m=measuredf$thetam#dir moyenne
                        )
  measuredf<-measuredf[measuredf$date >= as.POSIXct(start,tz="GMT") & measuredf$date <= as.POSIXct(end,tz="GMT") ,]
  df.obs<-melt(measuredf,id=1)
  df.obs['Source']<-"Observation"
  
  df<-rbind(df.mod,df.obs)
  
  ## PAS TERRIBLE ##
  df<-df[df$value!=0.00 & df$value!=Inf,]
  
  # Change levelnames
  levels(df$variable) <- c("Hs(m)","PeakPeriod(s)","Dir(Deg)","MeanDir(Deg)")
  
  ggplot<-ggplot(df,aes(x=date,y=value,color=`Source`)) + facet_grid(variable~., scales='free')
#   ggplot<-ggplot(df,aes(x=date,y=value,color=`Source`)) + facet_grid(variable~.)
  ggplot<-ggplot + geom_line(data=df[df$variable=="Hs(m)", ]) + 
    geom_line(data=df[df$variable=="PeakPeriod(s)",]) +
    geom_point(data=df[df$variable=="Dir(Deg)",],alpha=2/3,size=1.2) +
    geom_point(data=df[df$variable=="MeanDir(Deg)",],alpha=2/3,size=1.2) +
     scale_colour_manual("Source", breaks = c("Observation", "Model"),values = c("lightgrey", "lightgreen")) +
    theme(panel.background = element_rect(fill="white")) +
#    ylim(0,7) +
    labs(title=paste("Buoy: ",station, " | Year: ", year,sep="")) 
  
  print(ggplot)
}





#### BACKUP #####
#MEASURE PART
#SOLTC SRC
#   measuredf.full<-read.csv(paste(paste("../../inputs/soltc/",station,sep=""),".csv",sep=""),header=TRUE,col.names=c("id","date","temp","temp_pt_rosee","sea_pressure","wnd","wnd_dir","gust","humidity","tension_vap","sst","hs","tmoy","consolidated","quai"))
#   measuredf.full['date']<-as.POSIXct(measuredf.full$date,tz="Etc/GMT-12",format='%Y-%m-%d %H:%M:%S')
#   measuredf.full['temp']<-as.numeric(as.character(measuredf.full$temp))
#   measuredf.full['temp_pt_rosee']<-as.numeric(as.character(measuredf.full$temp_pt_rosee))
#   measuredf.full['sea_pressure']<-as.numeric(as.character(measuredf.full$sea_pressure))
#   measuredf.full['wnd']<-as.numeric(as.character(measuredf.full$wnd))
#   measuredf.full['wnd_dir']<-as.numeric(as.character(measuredf.full$wnd_dir))
#   measuredf.full['gust']<-as.character(measuredf.full$gust)
#   measuredf.full['humidity']<-as.numeric(as.character(measuredf.full$humidity))
#   measuredf.full['tension_vap']<-as.numeric(as.character(measuredf.full$tension_vap))
#   measuredf.full['sst']<-as.numeric(as.character(measuredf.full$sst))
#   measuredf.full['hs']<-as.numeric(as.character(measuredf.full$hs))
#   measuredf.full['tmoy']<-as.numeric(as.character(measuredf.full$tmoy))
#   measuredf.full['consolidated']<-as.character(measuredf.full$consolidated)
#   
#   measuredf<-data.frame(date=measuredf.full$date,hs=measuredf.full$hs)
#   #measuredf<-measuredf[measuredf$date > as.POSIXct("2011-10-01 00:00:00",tz="GMT") & measuredf$date < as.POSIXct("2011-10-10 00:00:00",tz="GMT"),]
#   
#   #HYMEX SRC  
#   measuredf<-read.csv(paste("../../inputs/GOL-buoy-hymex/Lion_HS_",year,".dat",sep=""),sep=";",header=TRUE,col.names=c("date","hs"))
#   measuredf['date']<-as.POSIXct(measuredf$date,tz="Etc/GMT-12",format='%Y-%m-%d %H:%M:%S')
#   
#   #MERGE dfs
#   df.mix<-merge(modeldf,measuredf,by='date',suffixes=c(".modeled",".measured"))
#   
#   df.mix<-df.mix[df.mix$date > as.POSIXct(start,tz="GMT") & df.mix$date < as.POSIXct(end,tz="GMT"),]
#   
#   
#   #PLOT
#   pline<-ggplot(df.mix, aes(date)) + 
#     geom_line(aes(y = hs.measured,colour="measured"),alpha=1,size=0.5)+
#     geom_line(aes(y = hs.modeled,colour="modeled"),alpha=1/2,size=0.5)+
#     scale_colour_manual("", breaks = c("measured", "modeled"),
#                         values = c("lightgrey", "blue")) +
#     theme(panel.background = element_rect(fill="white"))+
#     ylab("Hs (m)") +
#     xlab(paste("Time (Year ",year,")",sep=""))+
#     labs(title=paste("Validation - ",buoy,sep=""))
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-pline-",station,".png",sep=""),width=8,height=6)
#   }
#   
#   ppoint<-ggplot(df.mix, aes(date)) + 
#     theme(panel.background = element_rect(fill="white"))+
#     geom_point(aes(y = hs.measured, colour = "measured"),alpha=1,size=2) +
#     geom_point(aes(y = hs.modeled, colour = "modeled"),alpha=1/2,size=2) + 
#     scale_colour_manual("", breaks = c("measured", "modeled"),
#                         values = c("lightgrey", "blue")) +
#     ylab("Hs (m)") +
#     labs(title=paste("Validation - ",buoy,sep=""))+
#     xlab(paste("Time (Year ",year,")",sep=""))
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-ppoint-",station,".png",sep=""),width=8,height=6)
#   }
#   
#   #QQPLOT
#   d<- as.data.frame(qqplot(df.mix$hs.modeled, df.mix$hs.measured, plot.it=FALSE))
#   #d<- rename(d, c("x"="modeled", "y"="observed"))
#   colnames(d)[1]<-'modeled'
#   colnames(d)[2]<-'observed'
#   qqp<- ggplot(d) + 
#     theme(panel.background = element_rect(fill="white"))+
#     geom_point(aes(x=sort(d$modeled), y=sort(d$observed))) +
#     geom_abline(slope=1,aes(colour="line")) +
#     xlab("Hs(m) model") + 
#     ylab("Hs(m) observation") +
#     labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))+
#     if (has2print) {
#       ggsave(paste("~/Desktop/",year,"-qqpoint-",station,".png",sep=""),width=8,height=6)
#     }
#   
#   #d<-data.frame(modeled=df.mix$hs.modeled, observed=df.mix$hs.measured)
#   #qqp<-ggplot(d,aes(sample=d$observed))+stat_qq()
#   
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
