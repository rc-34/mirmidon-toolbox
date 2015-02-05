# Return the correlation coefficient of two time series (observed, simulated)
correlation <- function (obs,sim) {
  if (length(obs) != length(sim)) stop("CORRELATION : obs and sim timeseries are not of same length.")
  quot <- sum( (obs-mean(obs))*(sim-mean(sim)) )
  div <- sqrt ( sum((obs-mean(obs))^2) * sum((sim-mean(sim))^2) )
  return(quot/div)
}

# Return the relative bias of two time series (observed, simulated)
bias <- function (obs,sim) {
  if (length(obs) != length(sim)) stop("BIAS : obs and sim timeseries are not of same length.")
  return (mean(sim)-mean(obs))/mean(obs)
}

# Return the root mean squared error of two time series (observed, simulated)
rmse <- function (obs,sim) {
  if (length(obs) != length(sim)) stop("RMSE : obs and sim timeseries are not of same length.")
  return (sqrt(sum((obs-sim)^2)/length(obs)))
}

# Return the root mean squared relative error -- scatter index -- of two time series (observed, simulated)
si <- function (obs,sim) {
  if (length(obs) != length(sim)) stop("SI : obs and sim timeseries are not of same length.")
  return (sqrt( sum((obs-sim)^2) / sum(obs*obs) ))
}

# Return the maximum error between two time series (observed, simulated)
maxerr <- function (obs,sim) {
  if (length(obs) != length(sim)) stop("ERRMAX : obs and sim timeseries are not of same length.")
  return (max(abs(obs-sim)))
}

scatterPlot <- function (obs,sim) {
  x <- rnorm(500, 0, 1); plot(obs,sim); qqline(x)
}

qqPlot <- function (obs,sim) {
  x <- rnorm(500, 0, 1); qqplot(obs,sim); qqline(x)
}

res <- list()

stations=c("MeteoFranc","Espiguette","Sete","Leucate","Banyuls")#,"NICE","PORQUEROLLES")
extensions<-c("ZWND10","ZWND6")
year<-"2012"
for (station in stations) {
  for (extension in extensions) {
    station=c("MeteoFranc")
    extension<-c("ZWND6")
    df <- get(paste(station,year,"extracted",sep="."))
    df[,"date"] <- strftime(df[,"date"],format="%Y-%m-%d %H:%M:%S")
    dates <- df[df[,'variable'] %in% "Hs(m)" & df[,'Source'] %in% paste("Model",extension,sep="-")  ,'date']
    obs<-df[df[,'variable'] %in% "Hs(m)" & df[,'Source'] %in% "Buoy" & df[,'date'] %in% dates ,'value']
    dates <- df[df[,'variable'] %in% "Hs(m)" & df[,'Source'] %in% "Buoy"  ,'date']
    sim<-df[df[,'variable'] %in% "Hs(m)" & df[,'Source'] %in% paste("Model",extension,sep="-") & df[,'date'] %in% dates ,'value']
    
    c <- correlation(sim,obs)
    b <- bias(sim,obs)
    r <- rmse(sim,obs)
    s <- si(sim,obs)
    e <- maxerr(sim,obs)
    assign(paste(station,extension,sep="."), list("correlation" = c, "bias" = b, "rmse" = r, "si" = s,"errormax" = e))
    res <- c(res, list(get(paste(station,extension,sep="."))))
    
  }
}

