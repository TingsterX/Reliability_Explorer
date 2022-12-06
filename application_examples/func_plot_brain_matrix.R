# plot function 
library(ggplot2)


plot_matrix_Glasser <- function(M, cmap, gtitle="") {
 p <-  ggplot(reshape2::melt(M), aes(x=Var1, y=Var2, fill=value)) + 
    geom_raster() +
    scale_fill_gradientn(colours=cmap,name="",limits=c(0, 2*pi)) +
    xlab("x") + ylab("y") + coord_fixed(ratio=1) +
    ggtitle(gtitle) + scale_y_reverse() +
    #theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
    #      axis.ticks.x = element_blank(), axis.text.x = element_blank(), 
    #      axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
    geom_rect(aes(xmin = 5, xmax = 60, ymin = 5, ymax = 60),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 61, xmax =117, ymin = 61, ymax = 117),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 118, xmax =163, ymin = 118, ymax = 163),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 164, xmax =208, ymin = 164, ymax = 208),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 209, xmax =233, ymin = 209, ymax = 233),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 234, xmax =278, ymin = 234, ymax = 278),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 279, xmax =360, ymin = 279, ymax = 360),
              colour = "black", fill = NA, linewidth = 0.5) +
   theme_void()
 return(p)
}

plot_matrix_Schaefer7_200 <- function(M, cmap, gtitle="") {
  p <-  ggplot(reshape2::melt(M), aes(x=Var1, y=Var2, fill=value)) + 
    geom_raster() +
    scale_fill_gradientn(colours=cmap,name="",limits=c(0, 2*pi)) +
    xlab("x") + ylab("y") + coord_fixed(ratio=1) +
    ggtitle(gtitle) + scale_y_reverse() +
    #theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
    #      axis.ticks.x = element_blank(), axis.text.x = element_blank(), 
    #      axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
    geom_rect(aes(xmin = 1, xmax = 29, ymin = 1, ymax = 29),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 30, xmax =64, ymin = 30, ymax = 64),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 65, xmax =91, ymin = 65, ymax = 91),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 92, xmax =113, ymin = 92, ymax = 113),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 114, xmax =125, ymin = 114, ymax = 125),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 126, xmax =155, ymin = 126, ymax = 155),
              colour = "black", fill = NA, linewidth = 0.5) +
    geom_rect(aes(xmin = 156, xmax =200, ymin = 156, ymax = 200),
              colour = "black", fill = NA, linewidth = 0.5) +
    theme_void()
  return(p)
}