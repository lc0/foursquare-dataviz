FROM sergii/docker-shiny-server:latest

MAINTAINER Sergii Khomenko "khomenko@brainscode.com"

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    lib32z1-dev \
    libxml2-dev \
    libssl-dev

RUN R -e "install.packages(c('shiny', 'devtools', 'ggplot2', 'RCurl', 'leaflet', 'RJSONIO'), repos='https://cran.rstudio.com/')"
RUN R -e "devtools::install_github('ShinyDash', 'trestletech')"


COPY src /srv/shiny-server/foursquare-dataviz

# RUN R -e "setwd('/srv/shiny-server/foursquare-dataviz/'); library(shiny); runApp(port=3838, host = '0.0.0.0')"

CMD ["/bin/bash"]