FROM sergii/docker-shiny-server:latest

MAINTAINER Sergii Khomenko "khomenko@brainscode.com"

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    lib32z1-dev \
    libxml2-dev \
    libssl-dev

RUN R -e "install.packages(c('shiny', 'devtools', 'ggplot2', 'RCurl', 'leaflet', 'RJSONIO'), repos='https://cran.rstudio.com/')"
RUN R -e "devtools::install_github('ShinyDash', 'trestletech')"

EXPOSE 80

COPY docker/shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY docker/shiny-server.sh /usr/bin/shiny-server.sh
COPY src /srv/shiny-server/foursquare-dataviz

CMD ["/usr/bin/shiny-server.sh"]