library(raster)
library(ggplot2)


#read sites file
#sites.brut<-read.csv2(file="../inputs/sites/sites.xy",sep="\t",header=FALSE)
sites.brut<-read.csv2(file="../inputs/sites/sites-top10.xy",sep="\t",header=FALSE)
#format sites df
sites<-data.frame(Longitude=as.numeric(as.character(sites.brut$V1)),
                  Latitude=as.numeric(as.character(sites.brut$V2)),
                  name=sites.brut$V3)
sites$name<-gsub("[a-z]*\\[|\\]",'',sites$name)


if (require("maps")) {
  
  mask<-raster("/Users/rchailan/Desktop/R/inputs/coastline/mask.xyz")
  mask.p <- rasterToPoints(mask)
  maskdf <- data.frame(mask.p)
  colnames(maskdf) <- c("Longitude", "Latitude", "Land")
  maskdf$Land<-as.character(maskdf$Land)
  
  golmap <- ggplot(data=maskdf, aes(y=Latitude, x=Longitude)) +
    theme(legend.title = element_blank(),
          panel.background = element_rect(fill="white"))
    
  golmap <- golmap + geom_raster(aes(fill=Land)) + 
    scale_fill_manual(values=c("#006080", "#FFFFF1"), 
                      name="Mask",
                      breaks=c("0","1"),
                      labels=c("Sea","Land"))
   
  golmap <- golmap + geom_point(data=sites,size=I(2.5),alpha=I(0.5), color="Red") +
    geom_text(data=sites,aes(label=name),hjust=0, vjust=0)
  
}