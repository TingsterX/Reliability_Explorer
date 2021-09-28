# plot function
library(reshape2)
library(ggplot2)
library(scales)
library(RColorBrewer)
library(dplyr)

cmap_icc_list <- list(c(0, '#7b1c43'),  c(0.2, '#43435f'), c(0.3, "#5e5f91"), c(0.4, "#9493c8"), 
                      c(0.5, "#64bc46"), c(0.6, "#54b24c"), c(0.7, "#f6eb2b"), c(0.8, "#f5a829"), 
                      c(0.9, "#f07e27"), c(1, "#ec3625"), c(1, "#ec3625"))

plot.distance <- function(Dmax, gtitle='') {
  # plot distance matrix
  # Input: Dmax (distance matrix)
  xmin <- min(Dmax[Dmax>0])
  xmax <- max(Dmax)
  pdist <- ggplot(melt(Dmax), aes(x=Var1, y=Var2, fill=value)) + 
    geom_tile(color="grey") +
    scale_fill_gradientn(colours=c("blue","white", "red"), name="distance", limits=c(xmin, xmax)) +
    xlab("") + ylab("") + coord_fixed(ratio=1) +
    ggtitle(gtitle) + scale_y_reverse() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
          axis.ticks.x = element_blank(), axis.text.x = element_blank(), 
          axis.ticks.y = element_blank(), axis.text.y = element_blank())
  return(pdist)
}

# 
plot.distance_field_map <- function(dFM.df, ptype){
  # plot the distance field map
  # Input: distance_field_map.df(Dmax, subID)
  # x-axis: within-individual distance
  # y-axis: between-individual distance
  dFM.df$distance <- NULL
  dFM.df$distance[dFM.df$wD < dFM.df$bD] <- 'D_w < D_B'
  dFM.df$distance[dFM.df$wD > dFM.df$bD] <- 'D_w > D_B'
  
  dFMmin <- min(min(dFM.df$wD), min(dFM.df$bD))
  dFMmax <- max(max(dFM.df$wD), max(dFM.df$bD))
  dFMmargin <- (dFMmax - dFMmin)/20
  dFMmin <- max(dFMmin-dFMmargin, 0)
  dFMmax <- dFMmax+dFMmargin
  
  df_line <- data.frame(x=c(dFMmin, dFMmax), y=c(dFMmin, dFMmax))
  df_poly_above <- df_line
  df_poly_above[nrow(df_line)+1,] <- c(dFMmax, dFMmax)
  df_poly_above[nrow(df_line)+2,] <- c(dFMmin, dFMmax)
  
  if (ptype == 'Discr'){
  p <- ggplot(dFM.df,aes(wD, bD)) + 
    geom_point(aes(colour=distance, fill = distance), shape=21, size = 2) + 
    scale_fill_manual(values= c('#ff9987', 'grey80')) + 
    scale_color_manual(values = c('orangered2', 'grey10')) + 
    geom_abline(slope=1, intercept=0, color='forestgreen') +
    scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
    scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
    xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
    labs(color = "Discriminability") + guides(fill="none") +
    coord_equal() + theme(aspect.ratio=1) +
    theme_bw() 
  }
  else if (ptype == 'FP1'){
    p <- ggplot(dFM.df,aes(wD, bD)) + 
      geom_point(aes(colour=FPsub, fill = FPsub), shape=21, size = 2) + 
      scale_fill_manual(values= c('#ff9987', 'grey80')) + 
      scale_color_manual(values = c('orangered2', 'grey10')) + 
      geom_abline(slope=1, intercept=0, color='forestgreen') +
      scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
      scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
      xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
      labs(color = "Fingerprinting (sub)") + guides(fill="none") +
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else if (ptype == 'FP2'){
    p <- ggplot(dFM.df,aes(wD, bD)) + 
      geom_point(aes(colour=FPwithin, fill = FPwithin), shape=21, size = 2) + 
      scale_fill_manual(values= c('#ff9987', 'grey80')) + 
      scale_color_manual(values = c('orangered2', 'grey10')) + 
      geom_abline(slope=1, intercept=0, color='forestgreen') +
      scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
      scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
      xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
      labs(color = "Fingerprinting (repetition)") + guides(fill="none") +
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else if (ptype == 'Discr+FP1'){
    p <- ggplot(dFM.df,aes(wD, bD)) + 
      geom_point(aes(colour=FPsub, fill = FPsub), shape=21, size = 2) + 
      geom_polygon(data = df_poly_above, aes(x,y), fill = "red", alpha = .2) +
      scale_color_manual(values = c('orangered2', 'grey10')) + 
      scale_fill_manual(values= c('#ff9987', 'grey80')) + 
      geom_abline(slope=1, intercept=0, color='forestgreen') +
      scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
      scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
      xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
      guides(color="none", fill="none") + 
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else if (ptype == 'Discr+FP2'){
    p <- ggplot(dFM.df,aes(wD, bD)) + 
      geom_point(aes(colour=FPwithin, fill = FPwithin), shape=21, size = 2) + 
      geom_polygon(data = df_poly_above, aes(x,y), fill = "red", alpha = .2) +
      scale_color_manual(values = c('orangered2', 'grey10')) + 
      scale_fill_manual(values= c('#ff9987', 'grey80')) + 
      geom_abline(slope=1, intercept=0, color='forestgreen') +
      scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
      scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
      xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
      guides(color="none", fill="none") + 
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else if (ptype == 'all'){
    p <- ggplot(dFM.df,aes(wD, bD)) + 
      geom_point(aes(colour=FPsub, fill = FPwithin), shape=21, size = 2) + 
      geom_polygon(data = df_poly_above, aes(x,y), fill = "red", alpha = .2) +
      scale_color_manual(values = c('orangered2', 'grey10')) + 
      scale_fill_manual(values= c('#ff9987', 'grey80')) + 
      geom_abline(slope=1, intercept=0, color='forestgreen') +
      scale_x_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) + 
      scale_y_continuous(limits=c(dFMmin, dFMmax), expand = c(0, 0)) +
      xlab('Within-individual distance') + ylab('Observed Between-individual distance') +
      guides(color="none", fill="none") + 
      #labs(color = "Fingerprinting (sub)", fill="Fingerprinting (repetition)") +
      coord_equal() + theme(aspect.ratio=1) +
      theme_bw() 
  }
  else{
    cat("Specify the plot type: ptype=\"Discr\",\"FP1\", \"FP2\", \"Discr+FP2\", \"Discr+FP2\", \"all\" \n")
    cat("\"Discr\": Discriminability \n")
    cat("\"FP1\": Fingerprinting, count by subjects: \n")
    cat("         for each sub_i, count as \"identified\" only when all the within-sub_i distance < all between-sub_i ditance \n")
    cat("\"FP2\": Fingerprinting, count by subjects and repetitions: \n")
    cat("         for each sub_i(p,q), between p-th and q-th repetitions, count as \"identified\" if d(sub_i(p), sub-i(q)) < all ( d(sub_i(p), sub_j_*), d(sub_i(q),sub_j_*), i~=j ) \n")
    cat("\"Discr+FP1\": Show Discriminability (shaded) and Fingerprinting1 (red dots) in the same plot  \n")
    cat("\"Discr+FP2\": Show Discriminability (shaded) and Fingerprinting2 (red dots) in the same plot  \n")
    cat("\"all\": Show Discriminability (shaded), Fingerprinting1 (red dots with red borders), and Fingerprinting2 (red dots with black borders) in the same plot \n")
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
