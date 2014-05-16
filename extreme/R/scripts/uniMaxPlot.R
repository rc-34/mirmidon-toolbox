library(ggplot2) # for nice plots
library(reshape2)
library(scales)
library(plyr)

y<-1979
site<-35434

# extract max per months
max <- ddply(df.3,~ year + month,function(df){df[which.max(df$hs),]})
max$max<-TRUE

df.3$max<-FALSE
df.3max<-rbind(max,df.3)

# extract y year
df.3maxy<-df.3max[df.3max[,"year"]==y,]

# plot One year y
p1<-ggplot(df.3max,aes(as.Date(datetime),hs))+
  theme(legend.title = element_blank(),
        panel.background = element_rect(fill="white"))
# all points
p1<-p1+geom_point(data=df.3max[df.3max[,"year"]==y,],size=I(1.5),alpha=I(0.5), color="black")
# max
p1<-p1+geom_point(data=df.3max[df.3max[,"max"]==TRUE & df.3max[,"year"]==y ,],size=I(2.5),alpha=I(1), color="red")

pout <- p1+ ylab("Hs (m)") + xlab("Months") + labs(title=paste("Year ",y," - Site 35434",sep="")) + 
  scale_x_date(labels = date_format("%b"), breaks=date_breaks("month"))

# plot Any year
p2<-ggplot(df.3max,aes(as.Date(datetime),hs))+
  theme(legend.title = element_blank(),
        panel.background = element_rect(fill="white"))
for (i in 1961:1986) {  
  # all points
  p2<-p2+geom_point(data=df.3max[df.3max[,"year"]==i,],size=I(1.5),alpha=I(0.5), color="black")
  # max
  p2<-p2+geom_point(data=df.3max[df.3max[,"max"]==TRUE & df.3max[,"year"]==i ,],size=I(2.5),alpha=I(1), color="red")
}
pout2 <- p2+ facet_grid( . ~ year) + facet_wrap( ~ year,scales="free_x",ncol=5)+ ylab("Hs (m)") + 
  xlab("Months") +
  labs(title=paste("Years:",min(df.3max[,"year"]),"to", max(df.3max[,"year"]), "- Site ",site)) + 
  scale_x_date(labels = date_format("%b"), breaks=date_breaks("3 month"))

