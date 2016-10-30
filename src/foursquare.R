source("global.R")

addTrans <- function(color,trans) {
  # This function adds transparancy to a color.
  # Define transparancy with an integer between 0 and 255
  # 0 being fully transparant and 255 being fully visable
  # Works with either color and trans a vector of equal length,
  # or one of the two of length 1.
  
  if (length(color)!=length(trans)&!any(c(length(color),length(trans))==1)) stop("Vector lengths not correct")
  if (length(color)==1 & length(trans)>1) color <- rep(color,length(trans))
  if (length(trans)==1 & length(color)>1) trans <- rep(trans,length(color))
  
  num2hex <- function(x)
  {
    hex <- unlist(strsplit("0123456789ABCDEF",split=""))
    return(paste(hex[(x-x%%16)/16+1],hex[x%%16+1],sep=""))
  }
  rgb <- rbind(col2rgb(color),trans)
  res <- paste("#",apply(apply(rgb,2,num2hex),2,paste,collapse=""),sep="")
  return(res)
}



### windows users will need to get this certificate to authenticate
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

#foursquareData <- foursquare.getCheckins(foursquareToken, "20140119", "2013-01-01 00:00:00", "2013-12-31 23:59:49")
#foursquareData2013 <- foursquare.getCheckins(foursquareToken, "20140119", "2013-01-01 00:00:00", "2013-12-31 23:59:49")
#foursquareData2014 <- foursquare.getCheckins(foursquareToken, "20140119", "2014-01-01 00:00:00", "2014-12-31 23:59:49")

print("Visited countries")
length(table(foursquareData2013$country))
table(foursquareData2013$country)

print("Visited countries 2014")
length(table(foursquareData2014$country))
table(foursquareData2014$country)

print("Visited cities")
length(table(foursquareData2013$city))
table(foursquareData2013$city)

print("Visited cities 2014")
length(table(foursquareData2014$city))
table(foursquareData2014$city)

table(foursquareData2013$category)
posixDates <- as.POSIXct(as.numeric(foursquareData2013$created), origin="1970-01-01")
table(months(posixDates))

table(foursquareData2014$category)
posixDates <- as.POSIXct(as.numeric(foursquareData2014$created), origin="1970-01-01")
table(months(posixDates))

m <- as.data.frame(table(months(posixDates)))

#TODO: fix it for chronological ordering 
barplot(table(months(as.POSIXct(as.numeric(foursquareData2013$created), origin="1970-01-01"))))

barplot(table(months(as.POSIXct(as.numeric(foursquareData2014$created), origin="1970-01-01"))))

# -------------------------------------------------------------
# Data vizualization geo data with maps

# standart maps package
import.packages("maps")
import.packages("RgoogleMaps")

map('world',col="#292929",bg="black",fill=T,mar=rep(0,4),border=0, resolution=0, xlim = c(-180, 180), ylim = c(-90, 90))

for(i in 1:length(foursquareData$country)) {
  points(foursquareData$lng[i], foursquareData$lat[i], col="green", pch=16, lwd=1)
}


#Using RgoogleMaps module to display high quality maps from Google
bb <- qbbox(lat=foursquareData$lat, lon=foursquareData$lng,
            TYPE = "all", margin = list(m=rep(5,4), TYPE = c("perc", "abs")[1]));
MyMap <- GetMap.bbox(bb$lonR, bb$latR,destfile = "Foursquare.png", maptype = "terrain")

tmp <- PlotOnStaticMap(MyMap,lat=foursquareData$lat, lon=foursquareData$lng, pch=21,
                       cex = 1.5,verbose=0, bg=addTrans("green",100));

# -------------------------------------------------------------


map('world',col="#292929",bg="black",fill=T,mar=rep(0,4),border=0, resolution=0, xlim = c(-180, 180), ylim = c(-90, 90))

for(i in 1:length(foursquareData2014$country)) {
  points(foursquareData$lng[i], foursquareData$lat[i], col="green", pch=16, lwd=1)
}


#Using RgoogleMaps module to display high quality maps from Google
bb <- qbbox(lat=foursquareData2014$lat, lon=foursquareData2014$lng,
            TYPE = "all", margin = list(m=rep(5,4), TYPE = c("perc", "abs")[1]));
MyMap <- GetMap.bbox(bb$lonR, bb$latR,destfile = "Foursquare.png", maptype = "terrain")

tmp <- PlotOnStaticMap(MyMap,lat=foursquareData2014$lat, lon=foursquareData2014$lng, pch=21,
                       cex = 1.5,verbose=0, bg=addTrans("green",100));
