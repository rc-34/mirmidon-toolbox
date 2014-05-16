dirbin <- function (hsdir, ndir = 8, radians = FALSE) {
  hsbin<-c()
  dir.breaks <- rep(0, ndir)
  if (radians) {
    angleinc <- 2 * pi/ndir
    dir.breaks[1] <- pi/ndir
  }
  else {
    angleinc <- 360/ndir
    dir.breaks[1] <- 180/ndir
  }
  #bin range
  for (i in 2:ndir) dir.breaks[i] <- dir.breaks[i - 1] + angleinc
  
  print("dir bins")
  print(dir.breaks)
  
  #classification
  for (i in 1:length(hsdir)) {
    dir <- 1
    while (hsdir[i] > dir.breaks[dir] && dir < ndir) {
      dir <- dir + 1
    } 
    if (hsdir[i] > dir.breaks[ndir]) {
      dir <- 1
    }
    hsbin[i]<-dir
  }
  return(hsbin)
}