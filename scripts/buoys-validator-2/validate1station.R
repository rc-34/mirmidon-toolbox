source("readOunp2df.R")
source("readLionHymex.R")
source("readCandhis.R")
source("resources/r/Multiplot.R")

#-- Main Function --# validate 1 station / all variables available
validate1station <- function (station,year,candhisdir,hymexdir,ounpdir,plot = TRUE,
                              plotType = "full") {
  require(ggplot2)
  require(reshape2)
  require(grid)
  require(gridExtra)
  
  # read data
  df.obs <- readObservations(station,year,candhisdir,hymexdir)
  df.model <- readWW3Model(station,year,ounpdir)
  
  # restrict data along range
  start<-as.POSIXct(paste(year,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  end<-as.POSIXct(paste(year+1,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  df.obs <- df.obs[df.obs$date >= as.POSIXct(start,tz="GMT") & df.obs$date <= as.POSIXct(end,tz="GMT") ,]
  df.model <- df.model[df.model$date >= as.POSIXct(start,tz="GMT") & df.model$date <= as.POSIXct(end,tz="GMT") ,]
  
  # Gather data in one dataframe
  df<-merge(df.obs,df.model,by="date",all.y = TRUE)
  if (station != "61002") 
    colnames(df)<- c('date','obs.hs','obs.tp','obs.th1p','obs.th1m','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
  else
    colnames(df)<- c('date','obs.hs','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
  
  # Plot
  if (plot) {
    rangeYear <- c(year,year)
    switch (plotType,
            "full" = fullPlot(df,station,rangeYear),
            "qq"   = qqPlot(df,station,rangeYear),
            "ts"   = tsPlotlight(df,station,rangeYear))
    par(ask=FALSE)
  } else 
    return (df)
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

# plot Time series modeled against observations + qqplot
fullPlot <- function (df,station,rangeYear) {
  par(ask=TRUE)
  mfrow=c(1,1)
  tsPlot(df,station,rangeYear,mfrow)
  qqPlot(df,station,rangeYear)
}


# plot Time series modeled against observations
tsPlotlight <- function (df,station,rangeYear) {
  tsPlot(df,station,rangeYear,mfrow = c(4,1))
}

# plot Time series modeled against observations
tsPlot <- function (df,station,rangeYear,mfrow) {
  par(mfrow = mfrow)
  
  # preprocess year for title
  if (length(rangeYear == 2))
    rangeYearstring <- paste(rangeYear[1],rangeYear[2],sep="-")
  else
    reangeYearstring <- rangeYear
  
  # base layer plot
  baseplot<-ggplot(df,aes(x=date)) +
    scale_colour_manual(values=cbbPalette) +
    theme(panel.background = element_rect(fill="white")) +
    theme_bw() +
    theme(legend.position = c(0.90, 0.95)) + # c(0,0) bottom left, c(1,1) top-right.
    theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
    theme(text = element_text(size=20))+
    labs(title=paste(station,": ",rangeYearstring,sep=""))
  
  plots <- list()  # new empty list
  phs <- baseplot +
    geom_line(aes(y=df$obs.hs),alpha=2/3) +
    geom_line(aes(y=df$model.hs),alpha=2/3,size=1.2)
  #   plot(df$date,df$obs.hs,type='l',ylim = c(0,8))
  #   par(new=TRUE)
  #   plot(df$date,df$model.hs,type='l',ylim = c(0,8),col='red')
  plots[[1]] <- phs
  if (station != "61002") {
    # th1m = mean dir 
    pth1m <- baseplot +
      geom_point(aes(y=df$obs.th1m),alpha=2/3,size=1.2) +
      geom_point(aes(y=df$model.th1m),alpha=2/3,size=1.2) 
#     plot(df$date,df$obs.th1m,ylim = c(0,360))
#     par(new=TRUE)
#     plot(df$date,df$model.th1m,ylim = c(0,360),col='red')  
    plots[[2]] <- pth1m
    # th1p = peak dir 
    pth1p <- baseplot +
      geom_point(aes(y=df$obs.th1p),alpha=2/3,size=1.2) +
      geom_point(aes(y=df$model.th1p),alpha=2/3,size=1.2)
#     plot(df$date,df$obs.th1p,ylim = c(0,360))
#     par(new=TRUE)
#     plot(df$date,df$model.th1p,ylim = c(0,360),col='red')  
    plots[[3]] <- pth1p
    # peak period
    ptp <- baseplot +
      geom_line(aes(y=df$obs.tp),alpha=2/3) +
      geom_line(aes(y=df$model.tp),alpha=2/3,size=1.2)
#     plot(df$date,df$obs.tp,type='l',ylim = c(0,20))
#     par(new=TRUE)
#     plot(df$date,df$model.tp,type='l',ylim = c(0,20),col='red')  
    plots[[4]] <- pth1m
  } else {
    par(mfrow = c(1,1))
  }
  multiplot(plotlist = plots, cols = 1) 
}

# plot qqplot of model time series againt observations
qqPlot <- function (df,station,rangeYear) {
  #df2 <- df[!is.na(df$obs.hs),]
  qqplot(df$obs.hs,df$model.hs)
}