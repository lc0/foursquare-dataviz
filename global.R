library("RCurl")
library("RJSONIO")

# init foursquareToken with real tocken from
# https://foursquare.com/developers/apps
foursquareToken <- "FOURSQUARE-TOKEN-HERE"

import.packages <- function(pkg) {
  if (!require(pkg, character.only=TRUE)) {
    install.packages(pkg, dep=TRUE)
    require(pkg, character.only=TRUE)
  }
}

foursquare.getCheckins <- function(token, v, startStr, endStr){
  startTS <- as.numeric(as.POSIXct(startStr, format="%Y-%m-%d %H:%M:%S"))
  endTS <- as.numeric(as.POSIXct(endStr, format="%Y-%m-%d %H:%M:%S"))
  
  limit <- 250
  offset <- 0
  
  urlTemplate <- "https://api.foursquare.com/v2/users/self/checkins?oauth_token=%s&v=%s&afterTimestamp=%s&beforeTimestamp=%s&limit=%i&offset=%i"
  apiUrl <- sprintf(urlTemplate, token, v, startTS, endTS, limit, offset)
  json<-getURL(apiUrl, cainfo="cacert.pem")
  objects<-fromJSON(json, encoding="UTF-8")
  
  if (is.null(objects$response$checkins$count)) {
    print("Can't get api result, check your credentials")
    return()
  }
  
  count <- objects$response$checkins$count
  print(sprintf("Found %s events", count))
  
  name = vector("character", length=count)
  country = vector("character", length=count)
  city = vector("character", length=count)
  lat = vector("double", length=count)
  lng = vector("double", length=count)
  likes = vector("integer", length=count)
  category = vector("character", length=count)
  created = vector("character", length=count)
  
  while (offset < count) {
    urlTemplate <- "https://api.foursquare.com/v2/users/self/checkins?oauth_token=%s&v=%s&afterTimestamp=%s&beforeTimestamp=%s&limit=%i&offset=%i"
    apiUrl <- sprintf(urlTemplate, token, v, startTS, endTS, limit, offset)
    json<-getURL(apiUrl, cainfo="cacert.pem", .mapUnicode=TRUE)
    objects<-fromJSON(json)
    
    checkins <- objects$response$checkins$items
    
    # can't fetch anything after 750 checkins
    if (length(checkins) == 0) 
      break
    
    #TODO:simply with some sort of apply  
    for(n in 1:length(checkins)) {
      #skipping completely empty checkins
      if (!is.null(checkins[[n]]$venue)) {
        name[offset + n] = checkins[[n]]$venue$name
        country[offset + n] = checkins[[n]]$venue$location$country
        
        # short form to replace it
        city[offset + n] = ifelse(is.null(checkins[[n]]$venue$location$city), 
                                  NA, checkins[[n]]$venue$location$city)
        lat[offset + n] = checkins[[n]]$venue$location$lat
        lng[offset + n] = checkins[[n]]$venue$location$lng
        # likes[offset + n] = as.numeric(checkins[[n]]$venue$likes$count)
        category[offset + n] = ifelse(length(checkins[[n]]$venue$categories), 
                                      checkins[[n]]$venue$categories[[1]]$name, NA)
        created[offset + n] = checkins[[n]]$createdAt
        
      }
      
    }
    
    offset <- offset + limit
  }
  
  # Encoding(foursquareData$country) <- "utf8"
  # Encoding(foursquareData$city) <- "utf8"
  
  checkins.df<-as.data.frame(list(country=country, city=city, lat=lat, lng=lng, category=category, created=created, name=name), stringsAsFactors=FALSE)
  return(checkins.df)
}