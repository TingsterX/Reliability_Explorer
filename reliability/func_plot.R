# plot function
library(reshape2)
library(ggplot2)
library(scales)
library(ggridges)
library(RColorBrewer)
theme_set(theme_ridges())

distance_plot <- function(Dmax, gtitle) {
  # plot distance matrix
  # Input: Dmax (distance matrix)
  pdist <- ggplot(melt(Dmax), aes(x=Var1, y=Var2, fill=value)) + 
    geom_tile(color="grey") +
    scale_fill_gradientn(colours=c("blue","white", "red"), name="distance") +
    #scale_fill_gradientn(colours=c("#3c9ab2", "#ffffff", "#f22300"), name="distance") +
    #scale_fill_gradientn(colours = brewer.pal(9, 'GnBu'), name="distance") +
    xlab("") + ylab("") + coord_fixed(ratio=1) +
    ggtitle(gtitle) + scale_y_reverse() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
          axis.ticks.x = element_blank(), axis.text.x = element_blank(), 
          axis.ticks.y = element_blank(), axis.text.y = element_blank())
  return(pdist)
}

# 
distance_field_map.plot <- function(dFM.df, ptype){
  # plot the distance field map
  # Input: distance_field_map.df(Dmax, subID)
  # x-axis: within-individual distance
  # y-axis: between-individual distance
  dFM.df$distance <- NULL
  dFM.df$distance[dFM.df$wD < dFM.df$bD] <- 'D_w < D_B'
  dFM.df$distance[dFM.df$wD > dFM.df$bD] <- 'D_w > D_B'
  
  dFMmin <- min(min(dFM.df$wD), min(dFM.df$bD))
  dFMmax <- max(max(dFM.df$wD), max(dFM.df$bD))
  
  if (ptype == 'Discr'){
  p <- ggplot(dFM.df,aes(wD, bD, color=distance)) + 
    geom_point(shape=19, size=2) + 
    scale_color_manual(values = c('#ff471a', '#696969')) + 
    geom_abline(slope=1, intercept=0) +
    xlim(dFMmin, dFMmax) + ylim(dFMmin, dFMmax) +
    xlab('Within-individual distance') + ylab('Between-individual distance') +
    labs(color = "Discriminability") +
    coord_equal() + theme(aspect.ratio=1) +
    theme_bw() 
  }
  else if (ptype == 'FP1'){
    p <- ggplot(dFM.df,aes(wD, bD, color=FPsub)) + 
      geom_point(shape=19, size=2) + 
      scale_color_manual(values = c('#ff471a', '#696969')) + 
      geom_abline(slope=1, intercept=0) +
      xlim(dFMmin, dFMmax) + ylim(dFMmin, dFMmax) +
      xlab('Within-individual distance') + ylab('Between-individual distance') +
      labs(color = "Fingerprinting (sub)") +
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else if (ptype == 'FP2'){
    p <- ggplot(dFM.df,aes(wD, bD, color=FPwithin)) + 
      geom_point(shape=19, size=2) + 
      scale_color_manual(values = c('#ff471a', '#696969')) + 
      geom_abline(slope=1, intercept=0) +
      xlim(dFMmin, dFMmax) + ylim(dFMmin, dFMmax) +
      xlab('Within-individual distance') + ylab('Between-individual distance') +
      labs(color = "Fingerprinting (sub*scans)") +
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else{
    cat("Please specify the plot type: ptype=\"Discr\",\"FP1\" or \"FP2\"")
    cat("\"Discr\": Discriminability")
    cat("\"FP1\": Fingerprinting, count by subject: for each sub_i, count only the case that within-sub distance for sub_i < all ditance for sub_i")
    cat("\"FP2\": Fingerprinting, count by witin-sub distance: for each within-sub_i distance between scan m and n, count d_i(m,n) < all ( d(sub_i_m,sub_j), d(sub_i_n,sub_j) )")
  }
  
  return(p)
}


distance_field_map.df <- function(Dmax, subID){
  # write the distance matrix to a dataframe
  # label which within-sub d is from the same subj
  N <- dim(Dmax)[1]
  if (is.null((subID)) || N!=length(subID) ) {
    stop('Invalid Input')
  }
  subID <- as.character(subID)
  uniqids <- unique(subID)
  nsub <- length(uniqids)

  countvec <- vector(mode="numeric",length=nsub)
  for (s in 1:nsub) {
    countvec[s] <- sum(uniqids[s] == subID) # total number of scans for the particular id
  }
  nrow <- 0
  for (s in 1:nsub) {
    nrow <- nrow + sum(countvec[-s])*(countvec[s]*countvec[s]-countvec[s])
  }
  
  wD <- array(NaN, nrow)
  bD <- array(NaN, nrow)
  sub <- as.character(array(NaN, nrow))
  FPwithin <- array("Not identified", nrow)
  
  count <- 1
  for (s in 1:nsub) {
    ind <- which(subID == uniqids[s]) # indices that are the same subject
    for (i in ind) {
      di <- Dmax[i,] # get the i-th row
      nb <- length(di) - length(ind)
      for (j in ind){
        if (i!=j){
          wD[count:(count+nb-1)] <- rep(Dmax[i,j], nb)
          bD[count:(count+nb-1)] <- di[-ind]
          sub[count:(count+nb-1)] <- uniqids[s]
        
          # count identification (FPwithin)
          dj <- Dmax[j,] # get the i-th row
          db <- c(di[-ind], dj[-ind])
          if (Dmax[i,j] < min(db)){
            FPwithin[count:(count+nb-1)] <- "Identified"
          }
          
          count <- count + nb
        }
      }
    }
  }

  df <- data.frame(wD=wD, bD=bD, subID=sub, FPwithin=FPwithin, FPsub="Not identified")
  for (s in 1:nsub) {
    ind <- which(df$subID == uniqids[s]) # indices that are the same subject
    if(max(df$wD[ind]) < min(df$bD[ind])){df$FPsub[ind]="Identified"}
  }
  
  return(df)
}



# ----------

# ----------
hist_plot <- function(df, pxmin, pxmax){
  p <- ggplot(df, aes(x=value)) + xlim(pxmin, pxmax) + 
    geom_histogram(aes(y=..density..), position="identity", alpha=0)+
    geom_density(alpha=0.6) + 
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
          panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank())
  return(p)
}

# --------
reg_plot <- function(df) {
  p <- ggplot(df, aes(x=x, y=y)) + 
    geom_point(size=10, color="darkblue") + 
    geom_smooth(method=lm, se=FALSE, color="blue", size=5) + 
    theme_classic()
}
