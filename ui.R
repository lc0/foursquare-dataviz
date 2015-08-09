library(leaflet)
library(ShinyDash)

shinyUI(fluidPage(
  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  tags$head(tags$script(src="google-analytics.js")),

  tags$a(href="https://github.com/lc0/foursquare-dataviz", id="github-badge", "",
         tags$img(src="https://s3.amazonaws.com/github/ribbons/forkme_right_green_007200.png",
                  alt="Fork me on GitHub")
  ),

  leafletMap(
    "map", "100%", 500,
    initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(45.954779, 9.0808982),
      zoom = 4
    )
  ),
  fluidRow(
    column(8, offset=3,
           h2('Foursquare activity'),
           htmlWidgetOutput(
             outputId = 'desc',
             HTML(paste(
               'The map is centered at <span id="lat"></span>, <span id="lng"></span>',
               'with a zoom level of <span id="zoom"></span>.<br/>',
               'Selected <span id="shownCheckins"></span> checkins displayed in <span id="shownCities"></span> visible cities ',
               'and <span id="shownCountries"></span> countries.'
             ))
           )
    )
  ),
  hr(),
  fluidRow(
    column(2,
           selectInput('year', 'Year', years, 2014)
           # TODO: countries, types
    ),
    column(4,
           h4('Visible checkins'),
           tableOutput('checkins')
    ),
    column(6,
           h4(id='countriesPlotLabel', class='shiny-text-output'),
           plotOutput('countriesPlot', width='100%', height='500px'),
           h4(id='citiesPlotLabel', class='shiny-text-output'),
           plotOutput('citiesPlot', width='100%', height='500px')
    )
  )
))