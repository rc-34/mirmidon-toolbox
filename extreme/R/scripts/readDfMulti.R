library(ggplot2) # for nice plots
library(reshape2)
library(chron) # for leap function

source('~/Desktop/R/scripts/hsDir.R')

#read sites file
#sites.brut<-read.csv2(file="../inputs/sites/sites.xy",sep="\t",header=FALSE)
sites.brut<-read.csv2(file="../inputs/sites/sites-top10.xy",sep="\t",header=FALSE)
#format sites df
sites<-data.frame(Longitude=as.numeric(as.character(sites.brut$V1)),
                  Latitude=as.numeric(as.character(sites.brut$V2)),
                  name=sites.brut$V3)
sites$name<-gsub("[a-z]*\\[|\\]",'',sites$name)

year<-1986
doall<-FALSE
doall<-TRUE

if (doall) {
  for (site in sites$name) {
    # construct hs file path
    hsfile<-paste("../inputs/",year,"/",site,"/",year,"-hs-",site,".dat",sep="")  
    # read data from file
    hs.brut<-read.csv2(hsfile,sep="\t",header=FALSE) 
    
    # construct dir file path
    dirfile<-paste("../inputs/",year,"/",site,"/",year,"-dir-",site,".dat",sep="")
    # read data from file
    dir.brut<-read.csv2(dirfile,sep="\t",header=FALSE)
    
    # format data frame
    df<-data.frame(datetime=as.POSIXct(hs.brut$V1,tz="GMT",format='%Y-%m-%dT%H:%M:%S'),
                   hs=as.numeric(as.character(hs.brut$V2)),
                   dir=as.numeric(as.character(dir.brut$V2)),
                   site=as.character(hs.brut$V3))
    ## WARNING : NA from PHYSICAL Model is assumed as 0.00 Value (not encoded) ##
    df$hs[is.na(df$hs)] <- 0.00
    df$dir[is.na(df$dir)] <- 0.00
    
    df$year<-format(as.Date(df$datetime),"%Y")
    df$month<-months(df$datetime, abbreviate=TRUE)
    df$month<-factor(df$month,c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"))
#     df$dirbin<-dirbin(df$dir,ndir=8)
#     df$dirbin<-factor(df$dirbin,labels=c("N","NE","E","SE","S","SO","O","NO"))
    
    # 6 hours
    #df.6<-df[format(df$datetime,"%H")=="00" | format(df$datetime,"%H")=="06" | format(df$datetime,"%H")=="12" | format(df$datetime,"%H")=="18" ,]
    
    # 3 hours
    #df.3<-df[format(df$datetime,"%H")=="00" | format(df$datetime,"%H")=="03" | format(df$datetime,"%H")=="06" | format(df$datetime,"%H")=="09" | format(df$datetime,"%H")=="12" | format(df$datetime,"%H")=="15" | format(df$datetime,"%H")=="18" | format(df$datetime,"%H")=="21" ,]
    
    assign(paste(site,"_df",sep=""),df)
    
    # Extract month max
    max <- ddply(df,~ year + month,function(df){df[which.max(df$hs),]})
    assign(paste(site,"_max",sep=""),max)
  } 
}

