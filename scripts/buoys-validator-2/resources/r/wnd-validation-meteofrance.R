### WIND ###
#meteofrance wnd
measuredf<-data.frame(date=measuredf.full$date,wnd=measuredf.full$wnd)

#model wnd
modeldf<-read.csv(paste(paste("../../outputs/",station,sep=""),"-wnd.csv",sep=""),header=TRUE)
modeldf['date']<-as.POSIXct(modeldf$date,tz="GMT",format='%Y-%m-%d %H:%M:%S')
modeldf['wnd']<-as.numeric(modeldf$wnd)
modeldf['wnd']<-as.numeric(modeldf$wnd *3.6)
#MERGE dfs
df.mix<-merge(modeldf,measuredf,by='date',suffixes=c(".modeled",".measured"))
df.mix<-df.mix[df.mix$date > as.POSIXct("2011-10-01 00:00:00",tz="GMT") & df.mix$date < as.POSIXct("2011-10-30 00:00:00",tz="GMT"),]


#plot
pline<-ggplot(df.mix, aes(date)) + 
  geom_line(aes(y = wnd.modeled, colour = "modeled")) + 
  geom_line(aes(y = wnd.measured, colour = "observed")) +
  theme(axis.title.x = element_blank()) +
  ylab("Wnd (km/h)") +
  labs(colour = paste("Station",station,sep=": "))

ppoint<-ggplot(df.mix, aes(date)) + 
  geom_point(aes(y = wnd.modeled, colour = "modeled"),alpha=1/2,size=2) + 
  geom_point(aes(y = wnd.measured, colour = "observed"),alpha=1/2,size=2) +
  theme(axis.title.x = element_blank()) +
  ylab("Wnd (km/h)") +
  labs(colour = paste("Station",station,sep=": "))