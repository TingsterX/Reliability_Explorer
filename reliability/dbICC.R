#' Reliability - Distance-based Intraclass Correlation (dbICC)
#' 
#' A function for computing the dbICC of a dataset.
#' 
#' @param dmax [n, n]: a distance matrix for n observations 
#' @param subID [n]: a vector containing the subject IDs
#' @return dbicc: 
#' @note subID should match with the data (row)
#' @references: Meng Xu et al., 2021. Generalized reliability based on distances. Biometrics.https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7984087
#' 
#' @author: Ting Xu (https://github.com/TingsterX), Child Mind Institute, NY USA
#' @export


calc_dbICC <- function(dmax, subID, sortdata='TRUE') {
  # calculate the dbICC
  # convert the long format distance to matrix
  dmax <- as.matrix(dmax)
  # check the dimension
  if (length(subID) != dim(dmax)[1]){
    stop('check data: the number of subID and the dimension of distance matrix is not matched')
  }
  # default distance matrix should be sorted by subID
  if (sortdata == 'TRUE') {
    a <- sort(subID, index.return=TRUE)
    subID <- subID[a$ix]
    dmax <- dmax[a$ix, a$ix]
  } 
  # do the job
  n <- length(subID)
  wmask <- matrix(0,n,n)
  ii <- 1
  for (i in 2:n){
    if (subID[i] == subID[i-1]){ii <- ii+1}
    else{
      a <- matrix(0,ii,ii); a[upper.tri(matrix(1,ii,ii))] <- 1
      wmask[(i-ii):(i-1), (i-ii):(i-1)] <- a
      ii <- 1
    }
  }
  bmask <- upper.tri(matrix(1,n,n)) - wmask
  wmask[wmask == 0] <- NA
  bmask[bmask == 0] <- NA
  
  dbicc <- 1 - mean(dmax * wmask, na.rm = TRUE) / mean(dmax * bmask, na.rm = TRUE)
  return(dbicc)
}