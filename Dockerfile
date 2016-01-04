FROM sergii/docker-shiny-server:latest

MAINTAINER Sergii Khomenko "khomenko@brainscode.com"


RUN R -e "install.packages(c('shiny', 'rmarkdown', 'RGoogleAnalytics', 'devtools', 'ggplot2', 'shinyAce'), repos='https://cran.rstudio.com/')"

EXPOSE 80

# COPY docker/shiny-server.sh /usr/bin/shiny-server.sh
COPY src /srv/shiny-server/foursquare-dataviz

# RUN R -e "devtools::install_github('pingles/redshift-r')"

CMD ["/bin/bash"]