library("RCurl")
library("RJSONIO")

# init foursquareToken with real tocken from
# https://foursquare.com/developers/apps
foursquareToken <- "FOURSQUARE-TOKEN-HERE"

report.start_date <- "2012-01-01"
report.end_date <- "2014-12-31"


import.packages <- function(pkg) {
  if (!require(pkg, character.only=TRUE)) {
    install.packages(pkg, dep=TRUE)
    require(pkg, character.only=TRUE)
  }
}

foursquare.getCheckins <- function(token, v, startStr, endStr){
  checkins_cache = collection = paste('checkins', substr(startStr, 1, 10), substr(endStr, 1, 10), "4sqr.cache", sep="_")

  if(!file.exists(checkins_cache)) {
    startTS <- as.numeric(as.POSIXct(startStr, format="%Y-%m-%d %H:%M:%S"))
    endTS <- as.numeric(as.POSIXct(endStr, format="%Y-%m-%d %H:%M:%S"))

    limit <- 250
    offset <- 0

    name = vector("character")
    country = vector("character")
    city = vector("character")
    lat = vector("double")
    lng = vector("double")
    likes = vector("integer")
    category = vector("character")
    created = vector("character")

    while (TRUE) {
      urlTemplate <- "https://api.foursquare.com/v2/users/self/checkins?oauth_token=%s&v=%s&afterTimestamp=%s&beforeTimestamp=%s&limit=%i&offset=%i"
      apiUrl <- sprintf(urlTemplate, token, v, startTS, endTS, limit, offset)
      json<-getURL(apiUrl, cainfo="cacert.pem", .mapUnicode=TRUE)
      objects<-fromJSON(json)

      if (is.null(objects$response$checkins$count)) {
        print("Can't get api result, check your credentials")
        return()
      }

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
    print(sprintf("Fetched %s checkins", length(country)))

    checkins.df<-as.data.frame(list(country=country, city=city, lat=lat, lng=lng, category=category, created=created, name=name), stringsAsFactors=FALSE)
    write.table(checkins.df, file=checkins_cache)

    return(checkins.df)
  }
  else {
    print("File already exists on the disc, loaded from the disc")
    return(read.table(checkins_cache))
  }

}


foursquareData <- foursquare.getCheckins(foursquareToken, "20140119",
                                         sprintf("%s 00:00:00", report.start_date),
                                         sprintf("%s 23:59:49",report.end_date))
foursquareData$year = format(as.POSIXct(as.numeric(foursquareData$created), origin="1970-01-01"), "%Y")

# filter out rows with NA
foursquareData <- subset(foursquareData, !is.na(foursquareData$country))
