source("readOunp2df.R")
source("readLionHymex.R")
source("readCandhis.R")
source("resources/r/Multiplot.R")
source("resources/r/ComparisonStats.R")

cbbPalette <- c("lightgrey", "purple", "green","black", "blue", "green", "purple" ,"red")
cbbPalette2 <- c( "green", "purple", "blue", "red")
max.hs <- 25
max.tp <- 40

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
  start<-as.POSIXct(paste(year,"01-01 01:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  end<-as.POSIXct(paste(year+1,"01-01 00:00:00",sep="-"),tz="GMT",format='%Y-%m-%d %H:%M:%S')
  df.obs <- df.obs[df.obs$date >= as.POSIXct(start,tz="GMT") & df.obs$date <= as.POSIXct(end,tz="GMT") ,]
  df.model <- df.model[df.model$date >= as.POSIXct(start,tz="GMT") & df.model$date <= as.POSIXct(end,tz="GMT") ,]
  
  # Gather data in one dataframe
  df<-merge(df.obs,df.model,by="date",all.y = TRUE)
  df.stats<-merge(df.obs,df.model,by="date")
  
  if (station != "61002") {
    colnames(df)<- c('date','obs.hs','obs.tp','obs.th1p','obs.th1m','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
    colnames(df.stats)<- c('date','obs.hs','obs.tp','obs.th1p','obs.th1m','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
  } else {
    colnames(df)<- c('date','obs.hs','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
    colnames(df.stats)<- c('date','obs.hs','model.hs','model.lm','model.th1p','model.th1m','model.fp','model.tp')
  }
  
  # Plot
  if (plot) {
    # Avoid nan values
    df.stats<-df.stats[!(is.na(df.stats$obs.hs)) & !(is.na(df.stats$model.hs)),]
    # Print Stats info for Hs
    str(comparisons(df.stats$obs.hs,df.stats$model.hs))
    
    # Filter data
    df<-filter(df,station)
  
    # Plot
    rangeYear <- c(year)
    switch (plotType,
            "full" = fullPlot(df,station,rangeYear),
            "qq"   = qqPlot(df,station,rangeYear),
            "ts"   = tsPlotlight(df,station,rangeYear))
    par(ask=FALSE)
  } else 
    return (df)
}

# validate data for series of several year
validate1stationRangeYear <- function (station,yearmin,yearmax,candhisdir,hymexdir,ounpdir,plot = TRUE,
                              plotType = "full") {
  if (yearmin < 1961 | yearmax > 2012 | yearmax < yearmin) 
    stop("Please verify date. Must be: 1960 < yearmin <= yearmax < 2013 ")
  
  df <- data.frame()
  for (year in seq(yearmin,yearmax)) {
    df.tmp <- validate1station(station,year,candhisdir,hymexdir,ounpdir,plot = FALSE)
    # Could be optimised. Observations are read n times for nothing...
    df <- rbind(df,df.tmp)
  }
  
  # Plot
  if (plot) {
    # Filter data
    df<-filter(df,station)
    
    rangeYear <- c(yearmin,yearmax)
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
  # preprocess year for title
  if (length(rangeYear) == 2)
    rangeYearstring <- paste(rangeYear[1],rangeYear[2],sep="-")
  else
    rangeYearstring <- rangeYear
  
  # base layer plot
  baseplot<-ggplot(df,aes(x=date)) +
    scale_colour_manual(values=cbbPalette) +
    theme(panel.background = element_rect(fill="white")) +
    theme_bw() +
    theme(legend.position = c(0.90, 0.95)) + # c(0,0) bottom left, c(1,1) top-right.
    theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
    theme(text = element_text(size=20))+
    labs(title=paste(mapStationName(station)," (",station,")",": ",rangeYearstring,sep=""))
  
  plots <- list()  # new empty list
  
  phs <- baseplot +
    geom_line(aes(y=obs.hs),alpha=3/3,color=cbbPalette[1]) +
    geom_line(aes(y=model.hs),alpha=2/3,color=cbbPalette[2]) +
    xlab("date") + 
    ylab("Hs(m)")
  plots[[1]] <- phs
  if (station != "61002") {
    # peak period
    ptp <- baseplot +
      geom_line(aes(y=obs.tp),alpha=3/3,color=cbbPalette[1]) +
      geom_line(aes(y=model.tp),alpha=2/3,color=cbbPalette[2]) +
      xlab("date") + 
      ylab("Peak period(s)")
    plots[[2]] <- ptp
    
    # th1m = mean dir 
    pth1m <- baseplot +
      geom_point(aes(y=obs.th1m),alpha=3/3,size=2,color=cbbPalette[1]) +
      geom_point(aes(y=model.th1m),alpha=1/6,size=2,color=cbbPalette[2]) +
      xlab("date") +  ylab("Mean dir(deg)")
    plots[[3]] <- pth1m
    
    # th1p = peak dir 
    pth1p <- baseplot +
      geom_point(aes(y=obs.th1p),alpha=3/3,size=2,color=cbbPalette[1]) +
      geom_point(aes(y=model.th1p),alpha=1/6,size=2,color=cbbPalette[2]) +
      xlab("date") +  ylab("Peak dir(deg)")
    plots[[4]] <- pth1p
  } 
  if (mfrow[1]== 4) {
    multiplot(plotlist = plots, cols = 1)   
  } else {
    for (i in seq(1,length(plots))) {
      print(plots[[i]]) 
    }
  }
}

# plot qqplot of model time series againt observations
qqPlot <- function (df,station,rangeYear) {
  # preprocess year for title
  if (length(rangeYear) == 2)
    rangeYearstring <- paste(rangeYear[1],rangeYear[2],sep="-")
  else
    rangeYearstring <- rangeYear
  
  #QQPLOT
  tmp<-as.data.frame(qqplot(df$obs.hs,df$model.hs,plot.it=FALSE))
  colnames(tmp)[1]<-'observed'
  colnames(tmp)[2]<-'modeled'
  assign("qqp-vect",tmp)
  
  l<-ls(pattern='qqp-vect')
  d<-get(l[1])$observed
  for (i in (1:length(l))) {
    d<-cbind(d,get(l[i])$modeled)
  }
  d<-as.data.frame(d)
  names<-substr(x = l,start = 10,stop = 20)
  colnames(d)<-c('observed',as.vector(names))
  
  d2<-melt(d,id.vars = 1)
  qqp<- ggplot(d2,aes(x=observed,y=value)) + 
    theme(panel.background = element_rect(fill="white"))+
    theme(text = element_text(size=20))+
    theme_bw() +
    theme(legend.position = c(0.95, 0.8)) + # c(0,0) bottom left, c(1,1) top-right.
    theme(legend.background = element_rect(fill = "#ffffffaa", colour = NA))+
    xlab("Hs(m) Observation") + 
    ylab("Hs(m) Model") +
    labs(title=paste(mapStationName(station)," (",station,")",": ",rangeYearstring,sep="")) +
    #     scale_colour_manual("Model",values=cbbPalette2) +
    geom_point(size=1.5,shape=3,colour="black") +
    geom_abline(slope=1,colour="red",alpha=2/3)
  
  print(qqp)
}

# return a dataframe of usual statistics to compare two time series
comparisons <- function (obs,model) {
  df <- data.frame(
    "correlation" = correlation(obs,model),
    "bias" = bias(obs,model),
    "rmse" = rmse(obs,model),
    "si" = si(obs,model),
    "maxerr" = maxerr(obs,model)
    )
  return (df)
}

# filter df regarding potential NA & outliers values 
filter <- function(df,station) {
  df[is.na(df$obs.hs),'obs.hs'] <- 9999
  df[df$obs.hs  > max.hs,'obs.hs'] <- NA
  df[is.na(df$model.hs),'model.hs'] <- 9999
  df[df$model.hs > max.hs,'model.hs'] <- NA
  if (station != "61002") {
    df[is.na(df$obs.tp),'obs.tp'] <- 9999
    df[df$obs.tp   > max.tp,'obs.tp'] <- NA
    df[is.na(df$model.tp),'model.tp'] <- 9999
    df[df$model.tp > max.tp,'model.tp'] <- NA
  }
  return (df)
}