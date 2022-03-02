# get shiny 
FROM rocker/shiny:4.1.0

# system libraries 
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev

# install R packages required 
# RUN R -e 'remotes::install_github(c('rstudio/bslib', 'rstudio/thematic'))'
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinybusy', 'markdown', 'knitr'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('DT', 'reshape2'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('devtools', 'remotes'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('lme4')"
RUN R -e "remotes::install_github('neuroconductor/I2C2')"
RUN R -e "install.packages(c('ggplot2', 'plotly', 'rgl', 'stringr'), repos='http://cran.rstudio.com/')"


# copy the app to the image
COPY ./shiny /srv/shiny-server/rex

# select port
EXPOSE 3838

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server
# run app
CMD ["/usr/bin/shiny-server"]
