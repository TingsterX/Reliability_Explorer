#' calculate the Fingerprinting (Identification Rate)
#' 
#' A function for computing the Identification Rate of a dataset.
#' 
#' @param dist [n, n]: a distance matrix for n subjects.
#' @param sID [n]: a vector containing the subject ID for each subject.
#' @return FP [n]: Fingerprinting
#' @export

calc_fingerprinting <- function(dist, sID, method=1){
  # calcualte the fingerprinting
  # method=1: Count identification for each subject: if all(within-individual distance)<all(between-individual distance)
  # method=2: Count identification for each within-sub distance: if dist[i,j] < all(between-individual distance in the i-th and j-th rows)
  
  dist <- as.matrix(dist)
  N <- dim(dist)[1]
  if (is.null((N))) {
    stop('Invalid datatype for N')
  }
  
  # sort the distance matrix and sID
  a <- sort(sID, index.return=TRUE)
  ids <- sID[a$ix]
  dist <- dist[a$ix,a$ix]
  
  # count vector
  uniqids <- unique(as.character(ids))
  countvec <- vector(mode="numeric",length=length(uniqids))
  count_all_wD <- 0
  for (i in 1:length(uniqids)) {
    countvec[i] <- sum(uniqids[i] == ids) # total number of scans for the particular id
    count_all_wD <- count_all_wD + (countvec[i]-1)*(countvec[i])/2
  }
  
  nsub <- length(uniqids)
  FPsub <- array(NaN, nsub) # initialize empty array
  FPwithin <- array(0,dim=c(N,N))
  
  count_sub <- 0
  count_wD <- 0
  for (i in 1:nsub) {
    sub <- uniqids[i]
    ind <- which(ids == sub)
    nw <- length(ind)
    # count for each subject
    if (nw > 1){
      di <- dist[ind,]
      maski <- matrix(0,N,N)
      maski[ind,] <- 1
      w <- matrix(1,nw,nw); w[lower.tri(w)] <- 0; diag(w) <- 0
      maski_w <- matrix(0,nw,N)
      maski_w[,ind] <- w
      maski_b <- matrix(1,nw,N)
      maski_b[,ind] <- 0
      FPsub[i] <- max(di[maski_w>0]) < min(di[maski_b>0])
    }
    # count for each within-individual distance dist[i,j] and dist[j,i]
    for (i in ind) {
      for (j in ind){
        if (i!=j){
          di <- dist[i,] # get the i-th row
          dj <- dist[j,] # get the i-th row
          db <- c(di[-ind], dj[-ind])
          if (dist[i,j] < min(db)){
            FPwithin[i,j] <- 1
            }
        }
      }
    }
  }
  
  
  if (any(is.nan(FPsub))) {print("Warning: data contains subject(s) with one repetition")}
  if (method==1){
    FP <- sum(FPsub[!is.nan(FPsub)])/nsub
  }
  else if (method==2){
    FP <- (sum(FPwithin)/2)/count_all_wD
  }
  else{
    cat('calc_fingerprinting: Please specify method=1 or method=2')
    cat('1: count identification by each subject, 2: count by each within-sub distance')
    }
  
  return(FP)
}