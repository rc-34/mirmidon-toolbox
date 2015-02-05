require(ncdf)
require(lubridate)

readWW3OunpTime <- function(pathOunp){
  ounp.nc <- open.ncdf(pathOunp,readunlim = FALSE)
  
  time <- get.var.ncdf(ounp.nc,varid = "time")
  origin <- att.get.ncdf(ounp.nc,"time","units")$value
  origin <- substr(origin, start=11, stop = nchar(origin))
  time <- as.POSIXct(as.Date(time,origin = as.Date(origin)),tz = "GMT")  
  
  close.ncdf(ounp.nc)
  return (time)
}

## Read OUNP output [for a given station] from Wavewatch MEGAGOL2015-a and transform the data to a df
readWW3OunpStation <- function(station,pathOunp){
  # open ncfile
  ounp.nc <- open.ncdf(pathOunp,readunlim = FALSE)
  
  # Station index in ncfile regarding given station
  index.station <- 1
  stations <- get.var.ncdf(ounp.nc,"station_name")
  while ((stations[index.station] != station) & index.station <= length(stations)) {
    index.station <- index.station + 1
  }
  if (is.na(stations[index.station]))
    stop("Station not found in file from method readWW3OunpStation()")
  
  # Control on Station Name
  station.name <- get.var.ncdf(ounp.nc,"station_name", start = c(1,index.station), count = c(-1,1))
  print(paste("[Ounp-reading]",station.name))
  
  # Get time vector
  time <- readWW3OunpTime(pathOunp)
  time <- round(time,units="hours")
  
  # Get variables for the stations
  hs <- get.var.ncdf(ounp.nc,"hs", start = c(index.station,1), count = c(1,-1))
  lm <- get.var.ncdf(ounp.nc,"lm", start = c(index.station,1), count = c(1,-1))
  th1p <- get.var.ncdf(ounp.nc,"th1p", start = c(index.station,1), count = c(1,-1))
  th1m <- get.var.ncdf(ounp.nc,"th1m", start = c(index.station,1), count = c(1,-1))
  fp <- get.var.ncdf(ounp.nc,"fp", start = c(index.station,1), count = c(1,-1))
  
  # Create an output dataframe to gather results
  df.out <- data.frame("date" = time, "hs" = hs, "lm" = lm, "th1p" = th1p, "th1m" = th1m, "fp" = fp, "tp" = 1/fp)
  
  # close ncfile
  close.ncdf(ounp.nc)
  return (df.out)
}

