#remove nan row(s)
df.mix2<-df.mix[complete.cases(df.mix),]

#subselect time frame
#df.mix2<-df.mix2[df.mix2$date > as.POSIXct("2011-09-01 00:00:00") & df.mix2$date < as.POSIXct("2011-12-31 00:00:00"),]

#Plot error
hs.error<-(df.mix2$hs.modeled-df.mix2$hs.measured)
df<-data.frame(date=df.mix2$date,error=hs.error)
pline<-ggplot(df, aes(date)) + 
  geom_point(aes(y = error, colour = "error")) + 
  theme(axis.title.x = element_blank()) +
  ylab("Error (m)") +
  labs(colour = paste("Station","MeteoFrance",sep=": "))

#Compute errors metrics
error.mae<-(1/length(df.mix2$date))*sum(abs((df.mix2$hs.modeled-df.mix2$hs.measured)))
error.mse <- (1/length(df.mix2$date)) * (sum((df.mix2$hs.modeled-df.mix2$hs.measured)^2))
error.rmse <- sqrt(error.mse)
error.nrmse<- error.rmse/(max(df.mix2$hs.measured)-min(df.mix2$hs.measured))