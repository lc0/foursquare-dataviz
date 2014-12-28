library(leaflet)
library(ggplot2)
library(ShinyDash)

shinyServer(function(input, output, session) {

  map <- createLeafletMap(session, "map")

  session$onFlushed(once=TRUE, function() {
    foursquareData.noDate <- subset(foursquareData, year == 2014)
    foursquareData.noDate <- aggregate(checkins ~ name + country + city + lat + lng + category + year, data=foursquareData.noDate, FUN="length")

    "
    radiusFactor <- 200000
    map$addCircle(foursquareData.noDate$lat, foursquareData.noDate$lng,
                  radius=sqrt(foursquareData.noDate$checkins) * radiusFactor / max(5, input$map_zoom)^2,
                  options=list(
                    weight=1.2,
                    fill=TRUE,
                    color='#F00'
                  ))
    "

    map$addMarker(foursquareData.noDate$lat, foursquareData.noDate$lng)
  })


  values <- reactiveValues(selectedFeature = NULL)

  observe({
    evt <- input$map_click
    if (is.null(evt))
      return()

    isolate({
      # An empty part of the map was clicked.
      # Null out the selected feature.
      values$selectedFeature <- NULL
    })
  })

  observe({
    evt <- input$map_geojson_click
    if (is.null(evt))
      return()

    isolate({
      # A GeoJSON feature was clicked. Save its properties
      # to selectedFeature.
      values$selectedFeature <- evt$properties
    })
  })

  output$checkins <- renderTable({
    if (nrow(checkinsInBounds()) == 0)
      return(NULL)

    data.frame(
      Location = paste(checkinsInBounds()$country, checkinsInBounds()$city, sep=" / "),
      Category = checkinsInBounds()$category,
      Date = format(as.POSIXct(as.numeric(checkinsInBounds()$created), origin="1970-01-01"), "%Y-%m-%d %H:%M:%OS")
    )
  }, include.rownames = FALSE)


  # The cities that are within the visible bounds of the map
  checkinsInBounds <- reactive({

    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    newdf <- subset(foursquareData,
           lat >= latRng[1] & lat <= latRng[2] &
             lng >= lngRng[1] & lng <= lngRng[2] & year==checkinYear()
    )
    newdf <-droplevels(newdf)
  })



  checkinYear <- reactive({
    map$clearShapes()
    map$clearMarkers()

    foursquareData.noDate <- subset(foursquareData, year == input$year)
    foursquareData.noDate <- aggregate(checkins ~ name + country + city + lat + lng + category + year, data=foursquareData.noDate, FUN="length")

    "
    radiusFactor <- 200000
    map$addCircle(foursquareData.noDate$lat, foursquareData.noDate$lng,
                  radius=sqrt(foursquareData.noDate$checkins) * radiusFactor / max(5, input$map_zoom)^2,
                  options=list(
                    weight=1.2,
                    fill=TRUE,
                    color='#F00'
                  ))
    "
    map$addMarker(foursquareData.noDate$lat, foursquareData.noDate$lng)

    input$year
  })

  output$citiesPlot <- renderPlot({
    if (length(checkinsInBounds()) == 0) {
      return(NULL)
    }

    checkins <- table(checkinsInBounds()$city)
    if (length(checkins) > 0) {
      names_c <- names(checkins)
      cities_df <- data.frame(cities = names_c, checkins = as.vector(checkins))

      p <- ggplot(cities_df, aes(x=reorder(cities, - checkins), y=log(checkins))) +
        stat_summary(fun.y = sum, geom = "bar") +
        theme(axis.text.x=element_text(angle=90)) +
        geom_text(label=cities_df$checkins, vjust = -0.5)

      #p <- barplot(cities)

      print(p)
    }

  })
  output$countriesPlot <- renderPlot({
    if (length(checkinsInBounds()) == 0) {
      return(NULL)
    }

    checkins <- table(checkinsInBounds()$country)
    if (length(checkins) > 0) {
      names_c <- names(checkins)
      cities_df <- data.frame(countries = names_c, checkins = as.vector(checkins))

      p <- ggplot(cities_df, aes(x=reorder(countries, - checkins), y=log(checkins))) +
        stat_summary(fun.y = sum, geom = "bar") +
        theme(axis.text.x=element_text(angle=90)) +
        geom_text(label=cities_df$checkins, vjust = -0.5)

      #p <- barplot(checkins)

      print(p)
    }
  })

  output$countriesPlotLabel <- renderText({
    sprintf("Visited %i countries", length(table(checkinsInBounds()$country)))
  })

  output$citiesPlotLabel <- renderText({
    sprintf("Visited %i cities", length(table(checkinsInBounds()$city)))
  })

  observe({
    event <- input$map_marker_click
    if (is.null(event))
      return()
    map$clearPopups()

    #isolate({
    #  content <- as.character(tagList(
    #    tags$strong(paste(event)),
    #    tags$br()
    #  ))
    #  map$showPopup(event$lat, event$lng, content, event$id)
    #})
  })

  output$desc <- reactive({
    if (is.null(input$map_bounds))
      return(list())
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom,
      shownCheckins = nrow(checkinsInBounds()),
      shownCountries = length(table(checkinsInBounds()$country)),
      shownCities = length(table(checkinsInBounds()$city))
    )
  })

})