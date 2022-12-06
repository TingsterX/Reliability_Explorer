# some handy plot functions for this project
library(ggplot2)
library(ggridges)
library(RColorBrewer)
theme_set(theme_ridges())

# ---------------------------------------------
distance_plot <- function(Dmax, gtitle, xmin=NULL, xmax=NULL) {
  if (is.null(xmin)) xmin <- min(Dmax)
  if (is.null(xmax)) xmax <- max(Dmax)
  Dmax[Dmax>xmax] <- xmax
  # plot matlab-like   
  pdist <- ggplot(melt(Dmax), aes(x=X1, y=X2, fill=value)) + 
    geom_tile(color="white") +
    scale_fill_gradientn(colours=c("blue","white", "red"),name="distance",limits=c(xmin, xmax)) +
    xlab("x") + ylab("y") + coord_fixed(ratio=1) +
    ggtitle(gtitle) + scale_y_reverse() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
          axis.ticks.x = element_blank(), axis.text.x = element_blank(), 
          axis.ticks.y = element_blank(), axis.text.y = element_blank())

  return(pdist)
}

# ---------------------------------------------
reg_plot <- function(df, size.point=10, size.line=5) {
  p <- ggplot(df, aes(x=x, y=y)) + 
    geom_point(size=size.point, color="darkblue") + 
    geom_smooth(method=lm, se=TRUE, color="blue", size=size.line) + #coord_fixed(ratio=1) +
    theme_classic()
}

