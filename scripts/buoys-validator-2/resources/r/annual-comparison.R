require(ggplot2)
require(reshape2)

has2print<-FALSE

year<-"2012"
start<-"2012-01-01 00:00:00"
end<-"2012-12-31 23:00:00"

year<-"2011"
start<-"2011-01-01 00:00:00"
end<-"2011-12-31 23:00:00"

stations=c("MeteoFranc","Espiguette","Sete","Leucate","Banyuls")#,"NICE","PORQUEROLLES")
files=c("Lion_HS_","CANDHIS_export_pem_03001_Base","CANDHIS_export_pem_03404_Base",
        "CANDHIS_export_pem_01101_Base","CANDHIS_export_pem_06601_Base")#,"CANDHIS_export_pem_00601_Base","CANDHIS_export_pem_08301_Base")

cbbPalette <- c("lightgrey", "green", "purple", "blue","red")
cbbPalette2 <- c( "green", "purple", "blue", "red")

extensions<-c("ZWND10","ZWND6")
extensions<-c("ZWND6")

#For each stations
i<-1
for(station in stations) {
  file<-files[i]
  for (extension in extensions) {
    #MODEL PART
    #HS
    modeldf.hs<-read.csv(paste("../../outputs/",station,"-hs",extension,".csv",sep=""),header=TRUE,col.names=c("date","hs"))
    modeldf.hs['date']<-as.POSIXct(modeldf.hs$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    modeldf.hs['hs']<-as.numeric(modeldf.hs$hs)
    #fp - dominant wave frequency
    modeldf.fp<-read.csv(paste("../../outputs/",station,"-fp",extension,".csv",sep=""),header=TRUE,col.names=c("date","fp"))
    modeldf.fp['date']<-as.POSIXct(modeldf.fp$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    modeldf.fp['period']<-1/as.numeric(modeldf.fp$fp)
    modeldf.fp <- subset(modeldf.fp, select = -c(fp) )
    #th1m - mean wave direction
    modeldf.th1m<-read.csv(paste("../../outputs/",station,"-dir",extension,".csv",sep=""),header=TRUE,col.names=c("date","th1m"))
    modeldf.th1m['date']<-as.POSIXct(modeldf.th1m$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    modeldf.th1m['th1m']<-as.numeric(modeldf.th1m$th1m)
    #th1p - dominant wave direction
    modeldf.th1p<-read.csv(paste("../../outputs/",station,"-dirpeak",extension,".csv",sep=""),header=TRUE,col.names=c("date","th1p"))
    modeldf.th1p['date']<-as.POSIXct(modeldf.th1p$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    modeldf.th1p['th1p']<-as.numeric(modeldf.th1p$th1p)
    modeldf<-merge(modeldf.hs,
                   merge(modeldf.fp,
                         merge(modeldf.th1p,
                               modeldf.th1m)))
    modeldf<-modeldf[modeldf$date >= as.POSIXct(start,tz="UTC") & modeldf$date <= as.POSIXct(end,tz="UTC") ,]
    assign(paste("df.mod.",extension,sep = ""),melt(modeldf,id=1))
    Source<-rep(paste("Model-",extension,sep=""),nrow(get(paste("df.mod.",extension,sep = ""))))
    assign(paste("df.mod.",extension,sep = ""),cbind(get(paste("df.mod.",extension,sep = "")),Source))
  }

  #MEASURES/OBSERVATION PART
  if (station %in% "MeteoFranc") {
    #HYMEX SRC
    measuredf<-read.csv(paste("../../inputs/GOL-buoy-hymex/Lion_HS_",year,".dat",sep=""),sep=";",header=TRUE,col.names=c("date","hs"))
    measuredf['date']<-as.POSIXct(measuredf$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
  } else {
    measuredf<-read.csv(paste("../../inputs/candhis//donnees_candhis_cerema/",file,".csv",sep=""),sep=";",header=TRUE)
    measuredf$dateheure<-as.POSIXct(measuredf$dateheure,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    if(is.null(measuredf$hm0[1])) {hsignificant <- measuredf$h13d; print("Warning: Hm0 not available")} else {hsignificant <- measuredf$hm0}
    measuredf<-data.frame(date=measuredf$dateheure,
                          hs=hsignificant,#non spectral mais pas disponible
                          period=measuredf$tp,#periode moyenne
                          th1p=measuredf$thetap,#dir pic
                          th1m=measuredf$thetam#dir moyenne
                          ) 
  }
  measuredf<-measuredf[measuredf$date >= as.POSIXct(start,tz="UTC") & measuredf$date <= as.POSIXct(end,tz="UTC") ,]
  df.obs<-melt(measuredf,id=1)
  df.obs['Source']<-"Buoy"
  
  ##COMPARISONS##
  df<-df.obs
  for (extension in extensions) {
    df<-rbind(df,get(paste("df.mod.",extension,sep = "")))  
  }
  # Change levelnames
  levels(df$variable) <- c("Hs(m)","PeakPeriod(s)","Dir(Deg)","MeanDir(Deg)")
  
  # base layer plot
  ggplot<-ggplot(df,aes(x=date,y=value,color=`Source`)) + facet_grid(variable~., scales='free') +
    scale_colour_manual(values=cbbPalette) +
    theme(panel.background = element_rect(fill="white")) +
    theme_bw() +
    theme(legend.position = c(0.90, 0.95)) + # c(0,0) bottom left, c(1,1) top-right.
    theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
    theme(text = element_text(size=20))+
    labs(title=paste("Buoy: ",station, " | Year: ", year,sep=""))+
  geom_line(data=df[df$variable=="Hs(m)", ],,alpha=2/3) + 
  geom_line(data=df[df$variable=="PeakPeriod(s)",],alpha=2/3) +
  geom_point(data=df[df$variable=="Dir(Deg)",],alpha=2/3,size=1.2) +
  geom_point(data=df[df$variable=="MeanDir(Deg)",],alpha=2/3,size=1.2)
     
#   print(ggplot)
  if (has2print) {
    ggsave(paste("~/Desktop/",year,"-",station,".png",sep=""),width=20,height=7)
  }

  #QQPLOT
  for (extension in extensions) {
    tmp<-as.data.frame(qqplot(get(paste("df.mod.",extension,sep = ""))[get(paste("df.mod.",extension,sep = ""))$variable=="hs",'value'],
                            measuredf$hs,plot.it=FALSE))
    colnames(tmp)[1]<-'modeled'
    colnames(tmp)[2]<-'observed'
    assign(paste("qqp-vect.",extension,sep = ""),tmp)
  }
  l<-ls(pattern='qqp-vect.*')
  d<-get(l[1])$observed
  for (i in (1:length(l))) {
    d<-cbind(d,get(l[i])$modeled)
  }
  d<-as.data.frame(d)
  names<-substr(x = l,start = 10,stop = 20)
  colnames(d)<-c('observed',as.vector(names))

  d2<-melt(d,id.vars = 1)
  qqp<- ggplot(d2,aes(x=observed,y=value,color=variable)) + 
    theme(panel.background = element_rect(fill="white"))+
    theme(text = element_text(size=20))+
    theme_bw() +
    theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
    theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
    xlab("Hs(m) Observation") + 
    ylab("Hs(m) Modeled") +
    xlim(c(0,10))+
    ylim(c(0,10))+
    labs(title=paste("QQplot - ",station, " (",year,")",sep=""))+
    scale_colour_manual("Model",values=cbbPalette2) +
    geom_point(size=1.5,shape=3) +
    geom_abline(slope=1,colour="red",alpha=2/3)

  if (has2print) {
    ggsave(paste("~/Desktop/",year,"-qqplot-",station,".png",sep=""),width=15,height=5)
  }

  i<-i+1;
}