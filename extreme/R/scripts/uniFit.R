library(evd)

y<-1979
site<-35434
# extract max per months
max <- ddply(df.3,~ year + month,function(df){df[which.max(df$hs),]})


# subset May-June-July-August months
max<-max[max$month=="Jan" | max$month=="Feb" | max$month=="Mar" | max$month=="Apr" |
           max$month=="Sep" | max$month=="Oct" | max$month=="Nov" | max$month=="Dec" ,]



fit<-fgev(max$hs)
plot(fit)

## PLOTS ##
p1<-ggplot(max,aes(as.Date(datetime),hs))+
  theme(legend.title = element_blank(),
        panel.background = element_rect(fill="white"))
# all max
p1<-p1+geom_point(data=max,size=I(2.5),alpha=I(1), color="red")

pout <- p1+ ylab("Hs (m)") + xlab("Years") + labs(title=paste("Max (Without MJJA) - Site ",site)) + 
  scale_x_date(labels = date_format("%Y"), breaks=date_breaks("2 year"))