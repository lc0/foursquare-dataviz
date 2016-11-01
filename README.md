## R dataviz of Foursquare checkins
[![CircleCI](https://circleci.com/gh/lc0/foursquare-dataviz.svg?style=svg)](https://circleci.com/gh/lc0/foursquare-dataviz)
[![Docker Hub](https://img.shields.io/docker/pulls/sergii/foursquare-dataviz.svg "Docker Hub")](https://hub.docker.com/r/sergii/foursquare-dataviz/)


Screenshot of a running system:
![Screenshot of R-based Shiny app](https://raw.github.com/lc0/foursquare-dataviz/paper/screenshots/shiny-app.png)

<!---
![Tableau presentation of data](https://raw.github.com/lc0/foursquare-dataviz/paper/screenshots/tableau-screen.png)
-->

### Initial setup
Register ```FOURSQUARE_TOKEN``` from https://foursquare.com/developers/apps

Export your token as environment variable
```bash
export FOURSQUARE_TOKEN=your-token-here
```

Run pre-built image from [Docker hub](https://hub.docker.com/r/sergii/foursquare-dataviz/)
```bash
docker run -it -p 80:80 -e FOURSQUARE_TOKEN=${FOURSQUARE_TOKEN} docker.io/sergii/foursquare-dataviz:latest
```

### Development setup

Build Docker image from source:
```bash
make build
```


---
> Twitter [@lc0d3r](https://twitter.com/lc0d3r) &nbsp;&middot;&nbsp;
> GitHub [@lc0](https://github.com/lc0) &nbsp;&middot;&nbsp;
> [lc0.github.io](http://lc0.github.io) &nbsp;&middot;&nbsp;
