require(ggplot2)
require(reshape2)
has2print=FALSE

buoy<-"MeteoFrance"
year<-"2012"
start<-"2012-01-01 00:00:00"
end<-"2012-12-31 00:00:00"

#Declare Stations
stations=c("MeteoFranc")
extensions<-c("ZWND10","ZWND6")

cbbPalette <- c("lightgrey", "green", "purple", "blue","red")
cbbPalette2 <- c( "green", "purple", "blue", "red")

#For each stations
for(station in stations) {
  for (extension in extensions) {
    #MODEL PART
    modeldf<-read.csv(paste("../../outputs/",station,"-hs",extension,".csv",sep=""),header=TRUE,col.names=c("date","hs"))
    modeldf['date']<-as.POSIXct(modeldf$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
    modeldf['hs']<-as.numeric(modeldf$hs)
    
    assign(paste("df.mod.",extension,sep = ""),melt(modeldf,id=1))
    Source<-rep(paste("Model-",extension,sep=""),nrow(get(paste("df.mod.",extension,sep = ""))))
    assign(paste("df.mod.",extension,sep = ""),cbind(get(paste("df.mod.",extension,sep = "")),Source))
  }
  
  #MEASURE PART
  #HYMEX SRC  
  measuredf<-read.csv(paste("../../inputs/GOL-buoy-hymex/Lion_HS_",year,".dat",sep=""),sep=";",header=TRUE,col.names=c("date","hs"))
  measuredf['date']<-as.POSIXct(measuredf$date,tz="UTC",format='%Y-%m-%d %H:%M:%S')
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
#     geom_point()+
    geom_abline(slope=1,colour="red",alpha=2/3)
  
  if (has2print) {
    ggsave(paste("~/Desktop/",year,"-qqplot-",station,".png",sep=""),width=15,height=5)
  }
}
  
# 
#   #MERGE dfs
#   df.mix<-merge(modeldf,measuredf,by='date',all.x=TRUE,suffixes=c(".modeled",".measured"))
#   df.mix<-df.mix[df.mix$date > as.POSIXct(start,tz="UTC") & df.mix$date < as.POSIXct(end,tz="UTC"),]
#   
#   #PLOT
#   pline<-ggplot(df.mix, aes(date)) + 
#     geom_line(aes(y = hs.measured,colour="measured"),alpha=1,size=0.5)+
#     geom_line(aes(y = hs.modeled,colour="modeled"),alpha=1/2,size=0.5)+
#     scale_colour_manual("", breaks = c("measured", "modeled"),
#                         values = c("lightgrey", "green")) +
#     theme(panel.background = element_rect(fill="white"))+
#     ylab("Hs (m)") +
#   theme_bw() +
#   theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#   theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#   theme(text = element_text(size=20))+
#     xlab(paste("Time (Year ",year,")",sep=""))+
#   labs(title=paste("Validation - ",buoy,sep=""))
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-pline-",station,".png",sep=""),width=8,height=6)
#   }
#   
#   ppoint<-ggplot(df.mix, aes(date)) + 
#     theme(panel.background = element_rect(fill="white"))+
#   geom_point(aes(y = hs.measured, colour = "measured"),alpha=1,size=2) +
#     geom_point(aes(y = hs.modeled, colour = "modeled"),alpha=1/2,size=2) + 
#   scale_colour_manual("", breaks = c("measured", "modeled"),
#                       values = c("lightgrey", "green")) +
#     ylab("Hs (m)") +
#   theme_bw() +
#   theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#   theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#   theme(text = element_text(size=20))+
#     labs(title=paste("Validation - ",buoy,sep=""))+
#   xlab(paste("Time (Year ",year,")",sep=""))
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-ppoint-",station,".png",sep=""),width=8,height=6)
#   }
#   
#   #QQPLOT
#   df.mix2<-df.mix[!is.na(df.mix$hs.measured),]
#   #QQPLOT
#   d<-as.data.frame(qqplot(df.mix2$hs.modeled,df.mix2$hs.measured, plot.it=FALSE))
#   colnames(d)[1]<-'modeled'
#   colnames(d)[2]<-'observed'
#   qqp<- ggplot(d) + 
#   theme(panel.background = element_rect(fill="white"))+
#   geom_point(aes(x=sort(d$observed),y=sort(d$modeled)),size=1.5,shape=3) +
#   geom_abline(slope=1,aes(colour="line")) +
#   xlab("Hs(m) Observation") + 
#   ylab("Hs(m) Modeled") +
#   ylim(c(0,10))+
#   xlim(c(0,10))+
#   theme_bw() +
#   theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
#   theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
#   theme(text = element_text(size=20))+
#     labs(title=paste("QQplot - ",buoy, " (",year,")",sep=""))
#   if (has2print) {
#     ggsave(paste("~/Desktop/",year,"-qqpoint-",station,".png",sep=""),width=8,height=6)
#   }
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
# }