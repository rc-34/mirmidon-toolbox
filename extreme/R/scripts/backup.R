# extract yearly observation
#   for (i in 1961:1986) {
#     datemini<-paste(i,"-01-01 00:00:00",sep="")
#     datemaxi<-paste(i+1,"-01-01 00:00:00",sep="")
#     hs.zoom<-hs.formated[hs.formated$datetime > as.POSIXct(datemini,tz="GMT") & hs.formated$datetime < as.POSIXct(datemaxi,tz="GMT"),]
#     
#     # extract 29 feb date for comparing time series year / year
#     if (leap.year(i)) {
#       feb<-paste(i,"-02-29",sep="")
#       mar<-paste(i,"-03-01",sep="")
#       
#       hs.zoom.normalised<-hs.zoom[hs.zoom$datetime < as.POSIXct(feb,tz="GMT") | hs.zoom$datetime >= as.POSIXct(mar,tz="GMT"),]  
#       assign(paste(i,"hs.zoom.normalised",sep="."),hs.zoom.normalised) 
#     } else {
#       assign(paste(i,"hs.zoom.normalised",sep="."),hs.zoom) 
#     }
#     assign(paste(i,"hs.zoom",sep="."),hs.zoom) 
#   }
}





# bla<-hs.formated
# bla$MonthN<-as.numeric(format(as.Date(bla$datetime),"%m"))*30 # Month's number
# bla$MonthDay<-as.numeric(format(as.Date(bla$datetime),"%m"))*30+as.numeric(format(as.Date(bla$datetime),"%d"))*1+as.numeric(format(as.Date(bla$datetime),"%H"))/24
# bla$YearN<-as.numeric(format(as.Date(bla$datetime),"%Y")) # Month's number
# bla$Month<-months(as.Date(bla$datetime), abbreviate=TRUE) # Month's abbr.
# 
# g <- ggplot(data = bla, aes(x = MonthDay, y = hs, group=YearN, colour=YearN)) + 
#   geom_line() +
#   scale_x_discrete(breaks = bla$MonthN, labels = bla$Month)+
#   ylab("Hs (m)")+
#   xlab("Months")

#pline<-ggplot(`1961.hs.zoom`, aes(datetime)) + 
#    geom_line(aes(y = hs, colour = "1961")) + 
#    theme(axis.title.x = element_blank()) +
#    ylab("Hs (m)")
#    labs(colour = paste("Station",station,sep=": "))

#hs.zoom<-hs.formated[hs.formated$datetime > as.POSIXct("1962-01-01 00:00:00",tz="GMT") & hs.formated$datetime < as.POSIXct("1964-01-01 00:00:00",tz="GMT"),]