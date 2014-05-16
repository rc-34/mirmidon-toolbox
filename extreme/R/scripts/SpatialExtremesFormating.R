

# Extract All sites HS in 1 dataframe + Extract Location Matrix of sites
site<-paste(sites$name[1],"_max",sep="")
max<-get(site)
df<-data.frame(max$hs)
names<-c(site)
lon<-c(sites$Longitude[1])
lat<-c(sites$Latitude[1])
for (i in 2:length(sites$name)) {
  site<-paste(sites$name[i],"_max",sep="")
  max<-get(site)
  dftmp<-data.frame(max$hs)
  df<-cbind(df,dftmp)
  names<-c(names,site)
  
  lon<-c(lon,sites$Longitude[i])
  lat<-c(lat,sites$Latitude[i])
}
# Rename df column
colnames(df)<-names

# Bind lon and lat in a locations matrix
lon<-matrix(lon,ncol=1)
lat<-matrix(lat,ncol=1)
locations<-cbind(lon,lat)
colnames(locations) <- c("lon", "lat")
