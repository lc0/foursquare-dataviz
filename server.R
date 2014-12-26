library(leaflet)
library(ggplot2)

shinyServer(function(input, output, session) {
  
  map <- createLeafletMap(session, "map")

  #foursquareData <- list('2013' = f13, '2014' = foursquareData2014)

  # Encoding(foursquareData$city) <- "utf8"
  # foursquareData$city <- enc2native(foursquareData$city)
  # foursquareData$country <- enc2native(foursquareData$country)
  
  session$onFlushed(once=TRUE, function() {
    map$addMarker(foursquareData[["2014"]]$lat, foursquareData[["2014"]]$lng)
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
      Location = (sprintf("%s, %s", checkinsInBounds()$country, checkinsInBounds()$city)),
      Category = checkinsInBounds()$category,
      Date = format(as.POSIXct(as.numeric(checkinsInBounds()$created), origin="1970-01-01"), "%Y-%m-%d %H:%M:%OS")
    )
  }, include.rownames = FALSE)


  # The cities that are within the visible bounds of the map
  checkinsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(uspop2000[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    subset(foursquareData[[checkinYear()]],
           lat >= latRng[1] & lat <= latRng[2] &
             lng >= lngRng[1] & lng <= lngRng[2])
  })


  checkinYear <- reactive({
    map$clearShapes()
    map$clearMarkers()
    map$addMarker(foursquareData[[input$year]]$lat, foursquareData[[input$year]]$lng
                  #, list(title="foursquareData[[input$year]]$name")
                  )
    map$addCircle(foursquareData[[input$year]]$lat, foursquareData[[input$year]]$lng)
    
    # TODO: here we can have some caching and loading new years
    input$year
  })

  output$citiesPlot <- renderPlot({
    cities <- table(checkinsInBounds()$city)
    names_c <- names(cities)
    Encoding(names_c) <- 'utf8'

    cities_df <- data.frame(cities = names_c, checkins = as.vector(cities))
    
    p <- ggplot(cities_df, aes(x=reorder(cities, - checkins), y=log(checkins))) + 
      stat_summary(fun.y = sum, geom = "bar") +
      theme(axis.text.x=element_text(angle=90)) +
      geom_text(label=cities_df$checkins, vjust = -0.5)
    
    #p <- barplot(cities)
    
    print(p)
    
  })
  output$countriesPlot <- renderPlot({
    if (length(checkinsInBounds()) == 0) {
      return(NULL)
    }
    checkins <- table(checkinsInBounds()$country)

    names_c <- names(checkins)
    Encoding(names_c) <- "utf8"
    
    cities_df <- data.frame(cities = names_c, checkins = as.vector(checkins))
    
    p <- ggplot(cities_df, aes(x=reorder(cities, - checkins), y=log(checkins))) + 
      stat_summary(fun.y = sum, geom = "bar") +
      theme(axis.text.x=element_text(angle=90)) + 
      geom_text(label=cities_df$checkins, vjust = -0.5)
    
    #p <- barplot(cities)
    
    print(p)
    
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