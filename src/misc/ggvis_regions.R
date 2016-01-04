require("googleVis")
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

country_names <- c("Deutschland" , "Schweiz" , "España" , "United States" , "United Kingdom" ,
                   "Österreich" ,  "Україна" , "Italia" , "Magyarország" , "France" , "Slovensko" ,
                   "Česká republika" , "Nederland" , "Россия" , "Monaco" , "Црна Гора")

country_values <- c("Germany", "Switzerland", "Spain", "United States", "United Kingdom",
                    "Austria", "Ukraine", "Italy", "Hungary", "France", "Slovakia",
                    "Czech Republic", "Netherlands", "Russia", "Monaco", "Montenegro")

names(country_values) <- country_names

aggregated_checkins <- aggregate(checkins ~ country, data=foursquareData, FUN="length")

aggregated_checkins$country_en < NA
for (mapping in names(country_values)) {
  aggregated_checkins$country_en[aggregated_checkins$country == mapping] <- country_values[mapping]
}

aggregated_checkins$checkins <- 1
visited_countries <- gvisGeoMap(aggregated_checkins, locationvar='country_en', numvar = "checkins",
                                options=list(dataMode='regions', showLegend=F, showZoomOut=T, showZoomIn=T))
plot(visited_countries)

