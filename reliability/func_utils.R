#' Some utility functions
#' 
#' calculate the distance matrix (default: euclidean)
#' 
#' Example:
#' d <- calc_dist(data, subID)
#' calc_dbICC(d, subID)
#' calc_discriminability(d, subID)
#' calc_fingerprinting(d, subID)

calc_dist <- function(data, sID, method='euclidean') {
  # calculate the distance (dissimilarity) matrix
  # Data: data [n, p]: n observations x p variables
  D <- dist(data, method = method)
  return(D)
}

calc_discriminability <- function(dist, sID){
  # calculate the Discrmininability
  # source("reliability/discriminability.R")
  d <- discr.discr(discr.rdf(as.matrix(dist), sID))
  return(d)
}

calc_i2c2 <- function(data, sID, session){
  # install I2C2 package (https://rdrr.io/github/neuroconductor/I2C2)
  if (!require(I2C2)) {
    if (!require(remotes)) install.packages('package')
    remotes::install_github("neuroconductor/I2C2")
  }
  x <- I2C2::I2C2(as.matrix(data, nrow=length(sID)), sID, as.factor(session))
  return(x$lambda)
}

sort_data <- function(data, sID){
  # sort data based on the sID
  a <- sort(sID, index.return=TRUE)
  sID <- sID[a$ix]
  data <- data[a$ix,]
  return(data)
}