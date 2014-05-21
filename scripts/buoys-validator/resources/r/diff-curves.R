hs.dif<-(df.mix$hs.modeled-df.mix$hs.measured)

# define a data frame for polygon drawing
mini<-c()
maxi<-c()
for (i in seq(1:length(df.mix2$date))) {
  mini<-c(mini,min(df.mix2$hs.modeled[i],df.mix2$hs.measured[i]))
  maxi<-c(maxi,max(df.mix2$hs.modeled[i],df.mix2$hs.measured[i]))
}
df.mix3<-data.frame(x=c(df.mix2$date,rev(df.mix2$date)),y=c(mini,rev(maxi)))

# plot
pline<-ggplot(df.mix2, aes(date)) + 
  geom_line(aes(y = hs.modeled, colour = "modeled")) + 
  geom_line(aes(y = hs.measured, colour = "observed")) +
  geom_polygon(data = df.mix3,aes(x = x,y = y),fill = "lightblue",alpha = 0.55)+
  theme(axis.title.x = element_blank()) +
  ylab("Hs (m)") +
  labs(colour = paste("Station",station,sep=": "))
