# WindRose.R
require(ggplot2)
require(RColorBrewer)

plot.windrose <- function(spd,
                          dir,
                          spdres = 2,
                          dirres = 30,
                          spdmin = 2,
                          spdmax = 20,
                          spdseq = NULL,
                          palette = "YlGnBu",
                          countmax = NA,
                          debug = 0){
  # Tidy up input data ----
  n.in <- length(spd)
  dnu <- (is.na(spd) | is.na(dir))
  spd <- spd[!dnu]
  dir <- dir[!dnu]
  n.valid <- length(spd)
  
  
  # figure out the wind speed bins ----
  if (missing(spdseq)){
    spdseq <- seq(spdmin,spdmax,spdres)
  } else {
    if (debug >0){
      cat("Using custom speed bins \n")
    }
  }
  # get some information about the number of bins, etc.
  n.spd.seq <- length(spdseq)
  n.colors.in.range <- n.spd.seq - 1
  
  # create the color map
  speedcuts.colors <- colorRampPalette(brewer.pal(min(max(3,
                                                          n.colors.in.range),
                                                      min(9,
                                                          n.colors.in.range)),                                               
                                                  palette))(n.colors.in.range)
  
  if (max(spd,na.rm = TRUE) > spdmax){    
    speedcuts.breaks <- c(spdseq,
                          max(spd,na.rm = TRUE))
    speedcuts.labels <- c(paste(c(spdseq[1:n.spd.seq-1]),
                                '-',
                                c(spdseq[2:n.spd.seq])),
                          paste(spdmax,
                                "-",
                                max(spd,na.rm = TRUE)))
    speedcuts.colors <- c(speedcuts.colors, "grey50")
  } else{
    speedcuts.breaks <- c(seq(spdseq))
    speedcuts.labels <- paste(c(spdseq[1:n.spd.seq-1]),
                              '-',
                              c(spdseq[2:n.spd.seq]))
    
  }
  
  # Bin wind speed data ----
  spd.binned <- cut(spd,
                    breaks = speedcuts.breaks,
                    labels = speedcuts.labels,
                    ordered_result = TRUE)
  
  
  # figure out the wind direction bins
  dir.breaks <- c(-dirres/2,
                  seq(dirres/2, 360-dirres/2, by = dirres),
                  360+dirres/2)  
  dir.labels <- c(paste(360-dirres/2,"-",dirres/2),
                  paste(seq(dirres/2, 360-3*dirres/2, by = dirres),
                        "-",
                        seq(3*dirres/2, 360-dirres/2, by = dirres)),
                  paste(360-dirres/2,"-",dirres/2))
  # assign each wind direction to a bin
  dir.binned <- cut(dir,
                    breaks = dir.breaks,
                    ordered_result = TRUE)
  levels(dir.binned) <- dir.labels
  
  # create a data frame with the data in it ----
  windrose.data <- data.frame(spd.binned,
                              dir.binned)
  
  # Run debug if required ----
  if (debug>0){    
    cat(dir.breaks,"\n")
    cat(dir.labels,"\n")
    cat(levels(dir.binned),"\n")
    cat(speedcuts.colors, "\n")
    if (debug >1){
      cat(spd.binned,"\n")  
      cat(dir.binned,"\n")    
    }
  }  
  
  # create the plot ----
  plot.windrose <- ggplot(data = windrose.data,
                          aes(x = dir.binned,
                              fill = spd.binned)) +
    geom_bar() + 
    scale_x_discrete(drop = FALSE,
                     labels = waiver()) +
    coord_polar(start = -((dirres/2)/360) * 2*pi) +
    scale_fill_manual(name = "Hs (m)", 
                      values = speedcuts.colors,
                      drop = FALSE) +
    theme(axis.title.x = element_blank()) +
    
  
  # adjust axes if required
  if (!is.na(countmax)){
    plot.windrose <- plot.windrose +
      ylim(c(0,countmax))
  }
  
  # print the plot
  print(plot.windrose)
  
  
  # return the handle to the wind rose
  return(plot.windrose)
}