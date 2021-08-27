#' Intra-class correlation (ICC1) 
#'
#' A function for computing the Intra-class correlation (ICC) using Linear Mixed Model (ReML)
#' 1-way random model, Agreement, single and multiple raters 
#' ICC_a - 1-way random model, Agreement, single raters, defined as ICC(1,1)
#' ICCk_a - 1-way random model, Agreement, multiple raters, defined as ICC(1,k)
#' sigma2_b - sigma(between-sub)^2, estimated between-subject variation
#' sigma2_r - sigma(residual)^2, estimated within-subject variation
#' var(data) - variation of the data
#'
#' @param data [n, p]: a data matrix for n observation and p variables.
#' @param subID [n]: a vector containing the subject IDs for each subject.
#' @param session [n]: a vector containing the session (run, subsets, site, etc.)
#' @return ICC [5]: ICC_a, ICCk_a, sigma2_b, sigma2_r, variation of data
#' @author Ting Xu
#' @export

lme_ICC_1wayR <- function(data, subID, session) {
  library(lme4)
  
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  if (is.null((session)) || is.null((subID)) || n!=length(subID) || n!=length(session)) {
    stop('Invalid Input')
  }
  
  
  ICC <- array(0, dim=c(p,7))
  colnames(ICC) <- c("ICC_a", "ICCk_a", "sigma2_b", "sigma2_r", "var(data)", "error", "warning")
  
  for (i in 1:p){
    df <- data.frame(y=data[,i], subID = as.factor(subID), session = as.factor(session))
    tryCatch({
      fm_1wayR <- lmer(y ~ 1+ (1|subID), data=df, REML=TRUE) 
      k <- length(unique(df$session))
      output <- summary(fm_1wayR)
      sigma2_r = as.numeric(output$sigma^2)
      sigma2_b = as.numeric(output$varcor$subID)
      icc1R = sigma2_b/(sigma2_b + sigma2_r)
      icc1R_avg = sigma2_b/(sigma2_b + sigma2_r/(k))
      var_data = var(df$y)
      ICC[i,1:5] <- c(icc1R, icc1R_avg, sigma2_b, sigma2_r, var_data)
      ICC[i,6:7] <- 0
    }, 
    error = function(e){print(sprintf("LMM Error (column=%d): %s",i,e)); ICC[i,"error"]<<-1},
    warning = function(w){print(sprintf("LMM warning (column=%d): %s",i,w)); ICC[i,"warning"]<<-1}
    )
  }
  
  return(ICC)
}


#' Intra-class correlation (ICC2) 
#'
#' A function for computing the Intra-class correlation (ICC) using Linear Mixed Model (ReML)
#' 2-way random model, Agreement/Consistency, single and multiple raters 
#' ICC_a - 2-way random model, Agreement, single raters, defined ad ICC(2,1)
#' ICC_c - 2-way random model, Consistency, single raters
#' ICCk_a - 2-way random model, Agreement, multiple raters, defined ad ICC(2,k)
#' ICCk_c - 2-way random model, Consistency, multiple raters
#' sigma2_b - sigma(between-sub)^2, estimated between-subject variation
#' sigma2_s - sigma(session)^2,  estimated between-session variation
#' sigma2_r - sigma(residual)^2,  estimated within-subject variation
#' var(data) - variation of the data
#'
#' @param data [n, p]: a data matrix for n observation and p variables.
#' @param subID [n]: a vector containing the subject IDs for each subject.
#' @param session [n]: a vector containing the session (run, subsets, site, etc.)
#' @return ICC [8]: ICC_a, ICC_c, ICCk_a, ICCk_c, sigma2_b, sigma2_r, sigma2_session, var_data
#' @author Ting Xu
#' @export

lme_ICC_2wayR <- function(data, subID, session) {
  library(lme4)
  
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  if (is.null((session)) || is.null((subID)) || n!=length(subID) || n!=length(session)) {
    stop('Invalid Input')
  }
  
  ICC <- array(0, dim=c(p,10))
  colnames(ICC) <- c("ICC_a", "ICC_c", "ICCk_a", "ICCk_c", 
                     "sigma2_b", "sigma2_r", "sigma2_s", "var(data)",
                     "error", "warning") 
  
  for (i in 1:p){
    df <- data.frame(y=data[,i], subID = subID, session = session)
    tryCatch({
      fm_2wayR <- lmer(y ~ 1 + (1|session) + (1|subID), data=df, REML=TRUE) 
      k <- length(unique(df$session))
      output <- summary(fm_2wayR)
      sigma2_r = as.numeric(output$sigma^2)
      sigma2_b = as.numeric(output$varcor$subID)
      sigma2_session = as.numeric(output$varcor$session)
      icc2R_c = sigma2_b/(sigma2_b + sigma2_r)
      icc2R_a = sigma2_b/(sigma2_b + sigma2_r + sigma2_session)
      icc2R_c_avg = sigma2_b/(sigma2_b + sigma2_r/k)
      icc2R_a_avg = sigma2_b/(sigma2_b + (sigma2_session+sigma2_r)/k )
      var_data = var(df$y)
      ICC[i,1:8] <- c(icc2R_a, icc2R_c, icc2R_a_avg, icc2R_c_avg, sigma2_b, sigma2_r, sigma2_session, var_data)
      ICC[i,9:10] <- 0
    }, 
    error = function(e){print(sprintf("LMM Error (column=%d): %s",i,e)); ICC[i,"error"]<<-1},
    warning = function(w){print(sprintf("LMM warning (column=%d): %s",i,w)); ICC[i,"warning"]<<-1}
    )
  }
  
  return(ICC)
}


#' Intra-class correlation (ICC2) 
#'
#' A function for computing the Intra-class correlation (ICC) using Linear Mixed Model (ReML)
#' 2-way mixed model, Agreement/Consistency, single and multiple raters 
#' ICC_c - 2-way mixed model, Consistency, single raters, defined ad ICC(3,1)
#' ICCk_c - 2-way mixed model, Consistency, multiple raters, defined ad ICC(3,k)
#' sigma2_b - sigma(between-sub)^2, estimated between-subject variation
#' sigma2_r - sigma(residual)^2,  estimated within-subject variation
#' var(data) - variation of the data
#'
#' @param data [n, p]: a data matrix for n observation and p variables.
#' @param subID [n]: a vector containing the subject IDs for each subject.
#' @param session [n]: a vector containing the session (run, subsets, site, etc.)
#' @return ICC1 [5]: "ICC_c", "ICCk_c", "sigma2_b", "sigma2_r","var(data)"
#' @author Ting Xu
#' @export

lme_ICC_2wayM <- function(data, subID, session) {
  library(lme4)
  
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  if (is.null((session)) || is.null((subID)) || n!=length(subID) || n!=length(session)) {
    stop('Invalid Input')
  }
  
  ICC <- array(0, dim=c(p,7))
  colnames(ICC) <- c("ICC_c", "ICCk_c", "sigma2_b", "sigma2_r","var(data)", "error","warning") 
  
  for (i in 1:p){
    df <- data.frame(y=data[,i], subID = subID, session = session)
    tryCatch({
      fm_2wayM <- lmer(y ~ 1 + session + (1|subID), data=df, REML=TRUE) 
      k <- length(unique(df$session))
      output <- summary(fm_2wayM)
      sigma2_r = as.numeric(output$sigma^2)
      sigma2_b = as.numeric(output$varcor$subID)
      icc2M_c = sigma2_b/(sigma2_b + sigma2_r)
      icc2M_c_avg = sigma2_b/(sigma2_b + sigma2_r/k)
      var_data = var(df$y)
      ICC[i,1:5] <- c(icc2M_c,icc2M_c_avg, sigma2_b, sigma2_r,  var_data)
      ICC[i,6:7] <- 0
    }, 
    error = function(e){print(sprintf("LMM Error (column=%d): %s",i,e)); ICC[i,"error"]<<-1},
    warning = function(w){print(sprintf("LMM warning (column=%d): %s",i,w)); ICC[i,"warning"]<<-1}
    )
  }
  
  return(ICC)
}

