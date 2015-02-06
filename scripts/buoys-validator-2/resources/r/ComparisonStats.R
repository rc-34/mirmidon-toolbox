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

