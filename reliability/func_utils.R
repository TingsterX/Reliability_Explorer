#' Utility functions
#' 
#' calculate the distance matrix (default: euclidean)
#' 
#' Example:
#' d <- calc_dist(data, subID)
#' calc_dbICC(d, subID)
#' calc_discriminability(d, subID)
#' calc_fingerprinting(d, subID)
#' atan2_2pi: 



calc_dist <- function(data, sID, method='euclidean') {
  # calculate the distance (dissimilarity) matrix
  # Data: data [n, p]: n observations x p variables
  D <- dist(data, method = method)
  return(D)
}

calc_discriminability <- function(dist, sID, all_discr.return=FALSE){
  # calculate the Discrmininability
  # source("reliability/discriminability.R")
  # return all 
  d.all <- discr.discr(discr.rdf(as.matrix(dist), sID), all_discr.return)
  if (all_discr.return){
    return(d.all)
  }else{
    return(d.all[[1]])
  }
  
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

atan2_2pi <- function(y,x){
  # atan2 to calcualte theta, and convert theta: [0,2*pi)
  theta <- atan2(y, x)
  theta <- theta - 2*pi*apply(cbind(sign(theta),rep(0, length(theta ))), 1, min) 
  return(theta) 
}

calc_icc_gradient_flow <- function(df, df.ref, name=NULL, name.ref=NULL, return.input=FALSE){
  # df.ref: Input dataframe: contains sigma2_w, sigma2_b
  # df: Input dataframe: contains sigma2_w, sigma2_b
  if (!"sigma2_w" %in% colnames(df.ref) || !"sigma2_b" %in% colnames(df.ref) ||
      !"sigma2_w" %in% colnames(df) || !"sigma2_b" %in% colnames(df)){
    stop("Input dataframes require variables: sigma2_w, sigma2_b")
  }
  if (dim(df)[1] != dim(df.ref)[1]){
    stop("Please make sure that the rows of input dataframes are matched")
  }
  
  df.gradient <- gradient_flow(df$sigma2_w, df$sigma2_b, df.ref$sigma2_w, df.ref$sigma2_b)
  df.gradient$delta.icc <- df$icc - df.ref$icc
  df.gradient$contrast <- sprintf('%s-%s', name, name.ref)
  if (return.input){
    df.gradient$icc.1 <- df.ref$icc
    df.gradient$sigma2_w.1 <- df.ref$sigma2_w
    df.gradient$sigma2_b.1 <- df.ref$sigma2_b
    df.gradient$icc.2 <- df$icc
    df.gradient$sigma2_w.2 <- df$sigma2_w
    df.gradient$sigma2_b.2 <- df$sigma2_b
  }
  return(df.gradient)
}

gradient_flow <- function(x1, y1, x0, y0){
  # start point coordinate: x0=sigma2_w0, y0=sigma2_b0
  # end point coordinate:   x1=sigma2_w1, y1=sigma2_b1
  # Return: variation change (raw): var.delta.x, var.delta.y, var.theta
  #         variation change (normalize to reference line x=y): var.delta.x_norm, var.delta.y_norm, var.theta_norm
  # normalize the variance change vector reference line: x=y
  # rotation matrix [cos(theta), -sin(theta); sin(theta) cos(theta)]
  # x' = x*cos(theta) - y*sin(theta) 
  # y' = x*sin(theta) - y*cos(theta) 
  df <- data.frame(delta.sigma2_w = x1-x0, delta.sigma2_b = y1-y0)
  df$delta.theta <- atan2_2pi(y1-y0, x1-x0)
  
  theta0 <- atan2(y0,x0)
  rot <- 45*pi/180 - theta0
  
  df$delta.sigma2_w_norm <- cos(rot)*(x1-x0) - sin(rot)*(y1-y0)
  df$delta.sigma2_b_norm <- sin(rot)*(x1-x0) + cos(rot)*(y1-y0)
  df$delta.theta_norm    <- atan2_2pi(df$delta.sigma2_b_norm, df$delta.sigma2_w_norm) 
  
  return(df)
}

# --------------------------------
sort_data <- function(data, sID){
  # sort data based on the sID
  a <- sort(sID, index.return=TRUE)
  sID <- sID[a$ix]
  data <- data[a$ix,]
  return(data)
}

