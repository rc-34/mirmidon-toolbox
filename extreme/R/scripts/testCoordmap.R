library(raster)
library(ggplot2)

if (require("maps")) {
  # Create a lat-long dataframe from the maps package
  gol <- map_data("france",xlim=c(2.18,6.98),ylim=c(41.30,43.50))
  
  golmap <- ggplot(gol, aes(x=long, y=lat, group=group)) +
    geom_polygon(fill="black", colour="black")
  
  # Use cartesian coordinates
  golmap
  
  map<-raster("/Users/rchailan/Desktop/OnGoing/MEGAGOL/DATA/bathy/sirocco//megagol_sirocco.xyz")
  map.p <- rasterToPoints(map)
  df <- data.frame(map.p)
  colnames(df) <- c("Longitude", "Latitude", "Bathy")
  ggplot(data=df, aes(y=Latitude, x=Longitude)) +
    geom_raster(aes(fill=Bathy))
}