library(ggplot2) # for nice plots
library(reshape2)



#Seasonality
p1<-ggplot(df,aes(datetime,hs,color=year))+
  theme(legend.title = element_blank(),
       axis.text.x=element_blank(),
       panel.background = element_rect(fill="white"))

#for (i in 1961:1986) {  
for (i in 1961:1963) {  
  #p1<-p1+geom_line(data=df[df[,"year"]==i,],size=I(0.4),alpha=I(0.9))  
  p1<-p1+geom_point(data=df[df[,"year"]==i,],size=I(1),alpha=I(0.7))  
}

# #Plot classique
# pout <- p1+facet_grid(. ~ month)  + ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                                                 "to", max(df[,"year"]))) 
# pout <- p1+ facet_grid( . ~ year, scales = "free_x") + facet_wrap( ~ year,ncol=5 ) +  ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                               "to", max(df[,"year"])))

# Plot with associated direction
# pout <- p1+facet_grid(dirbin ~ month)  + ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                                                 "to", max(df[,"year"]))) 

# p1<-ggplot(df,aes(datetime,hs,color=dirbin))+
#   theme(legend.title = element_blank(),
#         axis.text.x=element_blank(),
#         panel.background = element_rect(fill="white"))
# for (i in 1:8) {  
#   p1<-p1+geom_point(data=df[as.numeric(df[,"dirbin"])==i,],size=I(1),alpha=I(0.7))  
# }
# pout <- p1+facet_grid( . ~ month) +  facet_wrap( ~ month,ncol=3) + coord_polar()  + ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                                                      "to", max(df[,"year"]))) 



# #Plot polaire
# pout <- p1+facet_grid(. ~ month) +  facet_wrap( ~ month,ncol=3) + coord_polar() + ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                                                 "to", max(df[,"year"]))) 

# pout <- p1+facet_grid(. ~ month) +  facet_wrap( ~ month,ncol=3) + coord_polar() + ylab("Hs (m)") + xlab(paste("Years:",min(df[,"year"]),
#                                                                 "to", max(df[,"year"]))) 



#plot.windrose(df$hs,df$dir,dirres=45,spdmin=0,spdmax=4,spdres=0.5)

