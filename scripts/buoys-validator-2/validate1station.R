source("readOunp2df.R")
source("readLionHymex.R")
source("readCandhis.R")

#-- Main Function --# validate 1 station / all variables available
validate1station <- function (station,year,candhisdir,hymexdir,ounpdir) {
  require(ggplot2)
  require(reshape2)
  
  df.obs <- readObservations(station,year,candhisdir,hymexdir)
  df.model <- readWW3Model(station,year,ounpdir)
  
  start<-as.POSIXct(paste(year,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  end<-as.POSIXct(paste(year+1,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  
  df.obs <- df.obs[df.obs$date >= as.POSIXct(start,tz="GMT") & df.obs$date <= as.POSIXct(end,tz="GMT") ,]
  df.model <- df.model[df.model$date >= as.POSIXct(start,tz="GMT") & df.model$date <= as.POSIXct(end,tz="GMT") ,]
  
  df<-merge(df.obs,df.model,by="date",all.y = TRUE)
  
  if (station != "61002") {
    colnames(df)<- c('date','obs.hs','obs.tp','obs.th1p','obs.th1m','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
    
    par(mfrow = c(4,1))
    # th1m = mean dir 
    plot(df$date,df$obs.th1m,ylim = c(0,360))
    par(new=TRUE)
    plot(df$date,df$model.th1m,ylim = c(0,360),col='red')  
    
    # th1p = peak dir 
    plot(df$date,df$obs.th1p,ylim = c(0,360))
    par(new=TRUE)
    plot(df$date,df$model.th1p,ylim = c(0,360),col='red')  
    
    # peak period
    plot(df$date,df$obs.tp,type='l',ylim = c(0,20))
    par(new=TRUE)
    plot(df$date,df$model.tp,type='l',ylim = c(0,20),col='red')  
    
    
  } else {
    par(mfrow = c(1,1))
    colnames(df)<- c('date','obs.hs','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
  }
  plot(df$date,df$obs.hs,type='l',ylim = c(0,8))
  par(new=TRUE)
  plot(df$date,df$model.hs,type='l',ylim = c(0,8),col='red')
  
}

# read observations from buoy code-named "station" in Megagol Hindcast
readObservations <- function (station,year,candhisdir,hymexdir) {
  print(paste("[Observation-reading]",station))
  if (station == "61002") {
    df.obs <- readLionHymex(year = year,hymexdir = hymexdir)
  } else {
    if (is.null(mapStationFileCode(station))) 
      warning(paste("Candhis file not available for station [",mapStationName(station),"/",station,"] won't be treated."),sep="")
    else
      df.obs <- readCandhis(station = station, year = year, candhisdir = candhisdir)
  }
  return (df.obs)
}

# read hindcast observation (hence modeled data) at location code-name "station" in Megagol Hindcast
readWW3Model <- function (station,year,ounpdir) {
  filepath <- paste(ounpdir,"/MEGAGOL2015a-OUNP-",year-1,"_tab.nc",sep="")
  df.model<-readWW3OunpStation(station,filepath)
  
  return (df.model)
}

# "61002" = "Lion",
# "61004" = "Porquerolles",
# "61005" = "Cap Corse",
# "61187" = "Nice",
# "61188" = "Banyuls",
# "61190" = "Sete",
# "61191" = "Leucate",
# "61289" = "Le Planier",
# "61431" = "Espiguette",

validate1station(station = "61002",
                 year = 2009,
                 candhisdir = "input/candhis/donnees_candhis_cerema", 
                 hymexdir = "input/GOL-buoy-hymex", 
                 ounpdir = "input/model/MEGAGOL2015-a/ounp")


# df.obs <- readObservations(station = "61190",
#                            year = 2009,
#                            candhisdir = "input/candhis/donnees_candhis_cerema", 
#                            hymexdir = "input/GOL-buoy-hymex")
# df.model <- readWW3Model(station = "61190",
#                          year = 2009,
#                          ounpdir = "input/model/MEGAGOL2015-a/ounp")
# 
# year <- 2009
# start<-as.POSIXct(paste(year,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
# end<-as.POSIXct(paste(year+1,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
# 
# df.obs <- df.obs[df.obs$date >= as.POSIXct(start,tz="GMT") & df.obs$date <= as.POSIXct(end,tz="GMT") ,]
# df.model <- df.model[df.model$date >= as.POSIXct(start,tz="GMT") & df.model$date <= as.POSIXct(end,tz="GMT") ,]
# 
# df<-merge(df.obs,df.model,by="date",all.y = TRUE)