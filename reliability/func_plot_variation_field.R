# plot function
library(reshape2)
library(ggplot2)
library(grid)
library(scales)
library(colorspace)
#library(ggridges)
library(RColorBrewer)
library(dplyr)

colormap.gradient.flow <- function(){
  # colormap for gradient flow
  df.tmp <- read.csv('colormap/colormap_reliability_gradient_flow.csv')
  cmap <- 255*as.matrix(df.tmp)
  return(cmap)
}

rgb2hex <- function(cmap.rgb){
  # convert RGB colormap (nx3 matrix) to a HEX color vector
  cmap.hex <- character(dim(cmap.rgb)[1])
  for (i in 1:dim(cmap.rgb)[1]){
    cmap.hex[i] <- rgb(cmap.rgb[i,1], cmap.rgb[i,2], cmap.rgb[i,3], maxColorValue = 255)
  }
  return(cmap.hex)
}

color.brewer.n <- function(n.color=NULL, pla.name="Set2"){
  # select n colors from RColorBrewer palettes
  # check all palettes: RColorBrewer::display.brewer.all()
  if (n.color<=brewer.pal.info[pla.name,]$maxcolors){
    cmap <- RColorBrewer::brewer.pal(brewer.pal.info[pla.name,]$maxcolors, pla.name)
    cmap <- cmap[1:n.color]
  }
  else{
    stop("# of colors of palette selected < number of colors required")
  }
  return(cmap)
}


# ----------------------------------------------------------------------------------
# variation field map and gradient flow map
# -----------------------------------------------------------------------------------

# add plotting point, combine with the density plot
plot.var.field <- function(df.plot, plot.title=NULL, 
                           axis.min=NULL, axis.max=NULL, plot.percent=c(0,1),
                           plot.point=TRUE, size.point = 2, color.point.fill="red", color.point.border="grey80",
                           plot.bin=FALSE, nbins=30, 
                           plot.density=FALSE, nbins.contour = 8, alpha.density = 1, 
                           color="red", ColorBrewer.direction=1, 
                           show.contour=FALSE, color.contour="grey30",
                           show.icc_slope=TRUE, color.icc_slope="grey50"){
  # df.plot: Input dataframe contains sigma2_w, sigma2_b
  # color: palette name from ColorBrewer, or a color array, e.g. c("blue", "red")
  #        If only one color provided, then it is filled by c("white", "red"). default="red"
  # direction: direction to use the palette from ColorBrewer
  # plot.percent: using the percentile to limit the x- and y-axis. default=c(0,1)
  # show.icc_slope: default=TRUE
  
  # Check the input dataframe
  if (!"sigma2_w" %in% colnames(df.plot) || !"sigma2_b" %in% colnames(df.plot)){
    stop("Input datafrmae in var_field_map_bin requires sigma2_w and sigma2_b")
  }
  df.plot <- df.plot[complete.cases(df.plot),]
  
  if (is.null(axis.min)){
    axis.min = min(min(df.plot$sigma2_w),min(df.plot$sigma2_b))
  }
  if (is.null(axis.max)){
    axis.max = max(max(df.plot$sigma2_w),max(df.plot$sigma2_b))
  }
  if (plot.percent[1]>0 || plot.percent[2]<1){
    axis.min = min(quantile(df.plot$sigma2_w, probs=c(plot.percent[1]), na.rm=TRUE),
                   quantile(df.plot$sigma2_b, probs=c(plot.percent[1]), na.rm=TRUE))
    axis.max = max(quantile(df.plot$sigma2_w, probs=c(plot.percent[2]), na.rm=TRUE),
                   quantile(df.plot$sigma2_b, probs=c(plot.percent[2]), na.rm=TRUE))
  }
  
  # Let's plot
  p <- ggplot(df.plot, aes(x=sigma2_w, y=sigma2_b, na.rm=TRUE)) +
    labs(x = "Within-Subject Variation", y="Between-Subject Variation", fill="") +
    coord_fixed(ratio = 1, xlim = c(axis.min, axis.max), ylim = c(axis.min, axis.max), 
                expand = FALSE, clip = "on") 
  
  # plot points
  if (plot.point && !plot.bin){
    p <- p + geom_point(shape=21, fill=color.point.fill, color=color.point.border, size=size.point) 
  }
  # plot 2D histogram
  if (plot.bin){
    p <- p + stat_bin_2d(bins=nbins)
    if (plot.density){
      message("Note: plot.bin and plot.density are both active. 2D histogram is plotted here")
    }
  }
  # plot 2D density
  if (!plot.bin && plot.density){
    p <- p + stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha=alpha.density, bins=nbins.contour, contour_var='count')
  }
  # Make custom for bin/density color
  if (plot.bin || plot.density){
    if (length(color)==1 && is.element(color, rownames(brewer.pal.info))){
     p <- p + scale_fill_distiller(palette= color, direction=ColorBrewer.direction, name="density")
   }
   else{
     if (length(color)==1){cmap <- c("white", color)}
     else{cmap = color}
     p <- p + scale_fill_gradientn(colours=cmap, name="density")
   }
  }
  # remove the colorbar tick label
  p <- p + guides(fill = guide_colourbar(label = FALSE))
  # plot the contour line
  if (show.contour){
    p <- p + geom_density_2d(size = 0.5, colour = color.contour, bins = nbins.contour, contour_var='count')
  }
  
  # show ICC slope ()
  if (show.icc_slope) {
    icc_slope=array(0, 10); i=1;
    for (z in seq(0,.9,by=0.1)){icc_slope[i]=z/(1-z); i=i+1}
    p <- p + geom_abline(size=0.25, slope=icc_slope, intercept =rep(0,10), colour=color.icc_slope) +
      #annotate(geom="text", x=axis.max*0.95, y=icc_slope[5]*axis.max*0.95, label='ICC=0.4', color="gray30", angle='39', size=3) +
      #annotate(geom="text", x=axis.max*0.95/icc_slope[7], y=axis.max*0.95, label='ICC=0.6', color="gray30", angle='60', size=3) +
      annotate(geom="text", x=axis.max*0.95, y=icc_slope[6]*axis.max*0.95, label='ICC=0.5', color="gray30", angle='45', size=3)
  }
  
  # show title
  if (!is.null(plot.title)){
    p <- p + ggtitle(plot.title)
  }
  # set theme
  p <- p + theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.background = element_blank(), 
          panel.background = element_rect(color='grey'))
  
  return(p)
}


plot.var.field.n <- function(df.plot, group.name="group", plot.title=NULL, 
                             axis.min=NULL, axis.max=NULL, plot.percent=c(0,1),
                             plot.point=TRUE, size.point = 2, color.point.line="grey50",
                             color=NULL, color.brewer.pla = "Set2", 
                             plot.density=FALSE, alpha.density = 0.5, 
                             show.contour=FALSE, nbins.contour = 8, color.contour=NULL,
                             show.icc_slope=TRUE, color.icc_slope="grey50"){
  # df.plot: Input dataframe contains sigma2_w, sigma2_b
  #          group: category variable that used for different groups
  # color: palette name from ColorBrewer, or a color array, e.g. c("blue", "red")
  # direction: direction to use the palette from ColorBrewer
  # plot.percent: using the percentile to limit the x- and y-axis. default=c(0,1)
  # show.icc_slope: default=TRUE
  
  # Check the input dataframe
  if (!"sigma2_w" %in% colnames(df.plot) || !"sigma2_b" %in% colnames(df.plot) || !group.name %in% colnames(df.plot) ){
    stop("Input dataframe requires variables: sigma2_w, sigma2_b, and specified group variable")
  }
  df.plot <- df.plot[complete.cases(df.plot),]
  df.plot$group <- df.plot[,group.name]
  
  if (is.null(axis.min)){
    axis.min = min(min(df.plot$sigma2_w),min(df.plot$sigma2_b))
  }
  if (is.null(axis.max)){
    axis.max = max(max(df.plot$sigma2_w),max(df.plot$sigma2_b))
  }
  if (plot.percent[1]>0 || plot.percent[2]<1){
    axis.min = min(quantile(df.plot$sigma2_w, probs=c(plot.percent[1]), na.rm=TRUE),
                   quantile(df.plot$sigma2_b, probs=c(plot.percent[1]), na.rm=TRUE))
    axis.max = max(quantile(df.plot$sigma2_w, probs=c(plot.percent[2]), na.rm=TRUE),
                   quantile(df.plot$sigma2_b, probs=c(plot.percent[2]), na.rm=TRUE))
  }
  
  # set color for point/density plot
  ngroup <- length(unique(df.plot$group))
  if (!is.null(color)) {
    if (length(color)<ngroup){
      stop("Please specify the color for each group")
    }else{
      cmap <- color
    }
  }
  else if (is.element(color.brewer.pla, rownames(brewer.pal.info)) 
           && ngroup<=brewer.pal.info[color.brewer.pla,]$maxcolors) {
    cmap <- color.brewer.n(ngroup, color.brewer.pla)
  }
  else{
    cmap <- hue_pal()(length(unique(df.plot$group)))
  }
  # set color for contour line (match point/density color)
  if (!is.null(color.contour) && length(color.contour)!=ngroup){
    stop("Please specify the contour color for each group")
  }
  if (!length(color.contour)==ngroup){
    color.contour <- darken(cmap, amount=0.1, space="combined")
  }
  
  # ------------------------------------------------------------
  # Let's plot
  p <- ggplot(df.plot, aes(x=sigma2_w, y=sigma2_b, na.rm=TRUE)) +
    labs(x = "Within-Subject Variation", y="Between-Subject Variation", fill="") +
    coord_fixed(ratio = 1, xlim = c(axis.min, axis.max), ylim = c(axis.min, axis.max), 
                expand = FALSE, clip = "on") 
  
  # plot points only
  if (plot.point && !plot.density){
    p <- p + geom_point(aes(fill=group), shape=21, size=size.point, color=color.point.line, na.rm=TRUE) 
    p <- p + scale_fill_manual(values = cmap) 
  }
  # plot points and density
  if (plot.point && plot.density){
    p <- p + geom_point(aes(fill=group), shape=21, size=size.point, color=color.point.line, na.rm=TRUE) + 
      stat_density_2d(aes(fill=group), alpha=alpha.density, geom = "polygon", bins=nbins.contour, contour_var='count', na.rm=TRUE) +
      guides(alpha="none")
    p <- p + scale_fill_manual(values = cmap)
  }
  # plot density
  if (!plot.point && plot.density){
    p <- p + stat_density_2d(aes(fill=group), alpha=alpha.density, geom = "polygon", bins=nbins.contour, contour_var='count', na.rm=TRUE) +
      guides(alpha="none")
    p <- p + scale_fill_manual(values = cmap)
  }
  # plot the contour line
  if (show.contour){
    p <- p + geom_density_2d(aes(colour=group), size = 0.5, bins = nbins.contour, contour_var='count')
    p <- p + scale_color_manual(values=color.contour)
  }
  
  # show ICC slope ()
  if (show.icc_slope) {
    icc_slope=array(0, 10); i=1;
    for (z in seq(0,.9,by=0.1)){icc_slope[i]=z/(1-z); i=i+1}
    p <- p + geom_abline(size=0.25, slope=icc_slope, intercept =rep(0,10), colour=color.icc_slope) +
      #annotate(geom="text", x=axis.max*0.95, y=icc_slope[5]*axis.max*0.95, label='ICC=0.4', color="gray30", angle='39', size=3) +
      #annotate(geom="text", x=axis.max*0.95/icc_slope[7], y=axis.max*0.95, label='ICC=0.6', color="gray30", angle='60', size=3) +
      annotate(geom="text", x=axis.max*0.95, y=icc_slope[6]*axis.max*0.95, label='ICC=0.5', color="gray30", angle='45', size=3)
  }
  # show title
  if (!is.null(plot.title)){
    p <- p + ggtitle(plot.title)
  }
  # set theme
  p <- p + theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.background = element_blank(), 
          panel.background = element_rect(color='grey'))

  return(p)
}


plot.var.change <- function(df.plot, plot.title=NULL, 
                            axis.min=NULL, axis.max=NULL, plot.percent=c(0,1), 
                            plot.point=TRUE, size.point=2, color.point.fill="blue", color.point.border="grey80",
                            plot.bin=FALSE, nbins=30, 
                            plot.density=FALSE, nbins.contour = 8, alpha.density = 1,
                            color="blue", ColorBrewer.direction=1,
                            show.contour=FALSE, color.contour="grey30",
                            show.quadr.line=TRUE, color.quadr.line="black"){
  # df: Input dataframe contains delta.sigma2_w, delta.sigma2_b
  # color: palette name from ColorBrewer, or a color array, e.g. c("blue", "red")
  #        If only one color provided, then it is filled by c("white", "red"). default="blue"
  # ColorBrewer.direction: direction to use the palette from ColorBrewer
  # plot.percent: using the percentile to limit the x- and y-axis. default=c(0,1)
  # show.quadr.line: Show quadrant line. default=TRUE
  
  if (!"delta.sigma2_w" %in% colnames(df.plot) || !"delta.sigma2_b" %in% colnames(df.plot) ){
    stop("Input datafrmae requires variables: delta.sigma2_w, delta.sigma2_b")
  }
  if (!"delta.theta" %in% colnames(df.plot)){
    df$delta.theta <- atan2_2pi(df.plot$delta.sigma_b, df.plot$delta.sigma_w)
  }
  df.plot <- df.plot[complete.cases(df.plot),]

  if (is.null(axis.min)){
    axis.min = -max(abs(rbind(df.plot$delta.sigma2_w, df.plot$delta.sigma2_b)))
  }
  if (is.null(axis.max)){
    axis.max = max(abs(rbind(df.plot$delta.sigma2_w, df.plot$delta.sigma2_b)))
  }
  if (plot.percent[1]>0 || plot.percent[2]<1){
    a = min(quantile(df.plot$delta.sigma2_w, probs=c(plot.percent[1]), na.rm=TRUE),
            quantile(df.plot$delta.sigma2_b, probs=c(plot.percent[1]), na.rm=TRUE))
    b = max(quantile(df.plot$delta.sigma2_w, probs=c(plot.percent[2]), na.rm=TRUE),
            quantile(df.plot$delta.sigma2_b, probs=c(plot.percent[2]), na.rm=TRUE))
    axis.min = -max(abs(a), abs(b))
    axis.max = max(abs(a), abs(b))
  }
  
  # ------------------------------------------------------------------------
  # Let's plot
  p <- ggplot(df.plot, aes(x=delta.sigma2_w, y=delta.sigma2_b, na.rm=TRUE)) +
    labs(x = "Change of Within-Subject Variation", y="Change of Between-Subject Variation", fill="") +
    coord_fixed(ratio = 1, xlim = c(axis.min, axis.max), ylim = c(axis.min, axis.max), 
                expand = FALSE, clip = "on") 
  
  if (!plot.point && !plot.bin && !plot.density && !show.contour){
    plot.point=TRUE
    message("Note: all plotting options are off, scatter plot is plotted here")}
  # plot points
  if (plot.point && !plot.bin){
    p <- p + geom_point(shape=21, fill=color.point.fill, color=color.point.border, size=size.point) 
  }
  # plot 2D histogram
  if (plot.bin){
    p <- p + stat_bin_2d(bins=nbins)
    if (plot.density){
      message("Note: both plot.bin and plot.density are active. 2D histogram is plotted here")
    }
    # Make custom for bin color
      if (length(color)==1 && is.element(color, rownames(brewer.pal.info))){
        p <- p + scale_fill_distiller(palette= color, direction=ColorBrewer.direction, name="count")
      }
      else{
        if (length(color)==1){cmap <- c("white", color)}
        else{cmap = color}
        p <- p + scale_fill_gradientn(colours=cmap, name="count")
      }
  }
  
  # plot 2D density
  if (!plot.bin && plot.density){
    p <- p + stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha=alpha.density, bins=nbins.contour, contour_var='count', na.rm=TRUE)
    # Make custom for bin/density color
      if (length(color)==1 && is.element(color, rownames(brewer.pal.info))){
        p <- p + scale_fill_distiller(palette= color, direction=ColorBrewer.direction, name="density")
      }
      else{
        if (length(color)==1){cmap <- c("white", color)}
        else{cmap = color}
        p <- p + scale_fill_gradientn(colours=cmap, name="density")
      }
    # remove the colorbar tick label
    p <- p + guides(fill = guide_colourbar(label = FALSE))
  }
  
  # show contour lines
  if (show.contour){
    p <- p + geom_density_2d(size = 0.5, colour = color.contour, bins = nbins.contour)
  }
  # show reference line x=0,y=0
  if (show.quadr.line){
    p <- p + geom_vline(xintercept = 0, size=0.5, colour=color.quadr.line) + 
      geom_hline(yintercept = 0, size=0.5, colour=color.quadr.line)
  }
  # show title
  if (!is.null(plot.title)){
    p <- p + ggtitle(plot.title)
  }
  # theme
  p <- p + theme_grey() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.background = element_blank(), 
          panel.background = element_rect(color='grey'))
  return(p)
}


plot.icc.gradient.norm <- function(df.plot, plot.title=NULL, 
                                   axis.min=NULL, axis.max=NULL, plot.percent=c(0,1), 
                                   plot.point=TRUE,  size.point=2, 
                                   color.point.gradient=FALSE,color.point.fill="red", color.point.border="grey80",
                                   plot.bin=FALSE, nbins=30, color.bin="red", direction=1,
                                   show.contour=FALSE, nbins.contour = 8, color.contour="grey30",
                                   show.ref.line=TRUE, show.ref.legend=TRUE){
  # df.plot: Input dataframe contains delta.sigma2_w, delta.sigma2_b
  # color: palette name from ColorBrewer, or a color array, e.g. c("blue", "red")
  #        If only one color provided, then it is filled by c("white", "red"). default="red"
  # direction: direction to use the palette from ColorBrewer
  # plot.percent: using the percentile to limit the x- and y-axis. default=c(0,1)
  # show.quadr.line: Show quadrant line. default=TRUE
  
  if (!"delta.sigma2_w_norm" %in% colnames(df.plot) || !"delta.sigma2_b_norm" %in% colnames(df.plot) ){
    stop("Input datafrmae requires variables: delta.sigma2_w_norm, delta.sigma2_b_norm")
  }
  if (!"delta.theta_norm" %in% colnames(df.plot)){
    df.plot$delta.theta_norm <- atan2_2pi(df.plot$delta.sigma2_b_norm, df.plot$delta.sigma2_w_norm)
  }
  
  df.plot <- df.plot[complete.cases(df.plot),]
  
  if (is.null(axis.min)){
    axis.min = -max(abs(rbind(df.plot$delta.sigma2_w_norm, df.plot$delta.sigma2_b_norm)))
  }
  if (is.null(axis.max)){
    axis.max = max(abs(rbind(df.plot$delta.sigma2_w_norm, df.plot$delta.sigma2_b_norm)))
  }
  if (plot.percent[1]>0 || plot.percent[2]<1){
    a = min(quantile(df.plot$delta.sigma2_w_norm, probs=c(plot.percent[1]), na.rm=TRUE),
            quantile(df.plot$delta.sigma2_b_norm, probs=c(plot.percent[1]), na.rm=TRUE))
    b = max(quantile(df.plot$delta.sigma2_w_norm, probs=c(plot.percent[2]), na.rm=TRUE),
            quantile(df.plot$delta.sigma2_b_norm, probs=c(plot.percent[2]), na.rm=TRUE))
    axis.min = -max(abs(a), abs(b))
    axis.max = max(abs(a), abs(b))
  }
  
  p <- ggplot(df.plot, aes(x=delta.sigma2_w_norm, y=delta.sigma2_b_norm, na.rm=TRUE)) +
    labs(x = "Relative Change of Within-Subject Variation", y="Relative Change of Between-Subject Variation", fill="") +
    coord_fixed(ratio = 1, xlim = c(axis.min, axis.max), ylim = c(axis.min, axis.max), 
                expand = FALSE, clip = "on") 
  
  
  # plot point 
  if (plot.point){
    if (plot.bin){message("Note: plot.point and plot.bin are both active. Scatter plot is plotted here")}
    if(color.point.gradient && is.null(color.point.border)){
      p <- p + geom_point(aes(colour=delta.theta_norm), shape=16, size=size.point) +
        scale_color_gradientn(colours=rgb2hex(colormap.gradient.flow()), name="change direction", limits=c(0, 2*pi), guide = "none")
    }
    if (color.point.gradient && !is.null(color.point.border)){
      p <- p + geom_point(aes(fill=delta.theta_norm), shape=21, size=size.point, color=color.point.border) +
        scale_fill_gradientn(colours=rgb2hex(colormap.gradient.flow()), name="change direction", limits=c(0, 2*pi), guide = "none")
    }
    if (!color.point.gradient && is.null(color.point.border)){
      p <- p + geom_point(shape=16, color=color.point.fill, size=size.point)
    }
    if (!color.point.gradient && !is.null(color.point.border)){
      p <- p + geom_point(shape=21, fill=color.point.fill, color=color.point.border, size=size.point)
    }
  }
  # plot 2D histogram only
  if (plot.bin && !plot.point){
    p <- p + stat_bin_2d(bins=nbins)
    if (length(color.bin)==1 && is.element(color.bin, rownames(brewer.pal.info))){
      p <- p + scale_fill_distiller(palette= color.bin, direction=direction, name="count")
    }else{
      if (length(color.bin)==1){cmap <- c("white", color.bin)}
      else{cmap = color.bin}
      p <- p + scale_fill_gradientn(colours=cmap, name="count")
    }
  }
  # plot contour
  if (show.contour){
    p <- p + geom_density_2d(size = 0.5, colour = color.contour, bins = nbins.contour, contour_var='count')
  }
  # plot reference line and legend
  if (show.ref.line){
    p <- p + geom_abline(size=0.5, slope=c(1,-1), intercept =rep(0,2), colour="black")
    p <- p + geom_vline(xintercept = 0, size=0.5, colour='grey50', linetype="dashed") + 
      geom_hline(yintercept = 0, size=0.5, colour='grey50', linetype="dashed")
  }
  if (show.ref.legend){
    p <- p + 
      geom_line(aes(x=x, y=y), data=data.frame(x=c(axis.min*.8, axis.min), y=c(axis.max*.8, axis.max)),
                arrow = arrow(length=unit(0.30,"cm"), ends="first", type = "closed")) + 
      geom_line(aes(x=x, y=y), data=data.frame(x=c(axis.max*.8, axis.max), y=c(axis.min*.8, axis.min)),
                arrow = arrow(length=unit(0.30,"cm"), ends="last", type = "closed")) + 
      annotate(geom="text", x=axis.max*0.85, y=axis.max*0.8, label='paste(Delta, "ICC=0")',color="grey10", angle='45', parse=TRUE) +
      annotate(geom="text", x=axis.min*0.8, y=axis.min*0.85, label='paste(Delta, "ICC=0")',color="grey10", angle='45', parse=TRUE) +
      annotate(geom="text", x=axis.min*0.78, y=axis.max*0.85, label="Optimal(+)",color="grey10", angle='315') +
      annotate(geom="text", x=axis.min*0.85, y=axis.max*0.78, label='paste(Delta, "ICC>0")',color="grey10", angle='315', parse=TRUE) +
      annotate(geom="text", x=axis.max*0.85, y=axis.min*0.78, label="Optimal(-)",color="grey10", angle='-45') +
      annotate(geom="text", x=axis.max*0.78, y=axis.min*0.85, label='paste(Delta, "ICC<0")',color="grey10", angle='-45', parse=TRUE) 
  }
  # show title
  if (!is.null(plot.title)){
    p <- p + ggtitle(plot.title)
  }
  # set theme
  p <- p + theme_grey() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.background = element_blank(), 
          panel.background = element_rect(color='grey'))
  
  return(p)
}


plot.icc.gradient.hist <- function(df.plot, plot.title=NULL,
                                   nbins = 40, show.ytick=FALSE, color.histline=NULL,
                                   show.ref.line=TRUE, show.ref.legend=TRUE){

  if (!"delta.theta_norm" %in% colnames(df.plot) ){
    stop("Input datafrmae requires variables: delta.theta_norm or delta.sigma2_b_norm, delta.sigma2_w_norm")
  }
  if (!"delta.theta_norm" %in% colnames(df.plot)){
    df.plot$delta.theta_norm <- atan2_2pi(df.plot$delta.sigma2_b_norm, df.plot$delta.sigma2_w_norm)
  }
  
  cmap <- rgb2hex(colormap.gradient.flow())  
  # plot histogram: cutted bar and set color for each bar
  #c <- cut(df$delta.theta_norm,breaks=pi*seq(0,2,length=nbins), include.lowest=TRUE)
  #cmap.cut <- cmap[floor(seq(0,360,length=nbins))]
  #p <- ggplot(df) +
    #geom_histogram(aes(delta.theta_norm, fill=c), binwidth = 2*pi/nbins, boundary=0, color='grey') +
    #scale_fill_manual(values=cmap.cut, guide = "none")
  
  p <- ggplot(df.plot) + coord_polar(start = -pi/2, direction=-1)
  # plot the histogram
  if (!is.null(color.histline)){
    p <- p + geom_histogram(aes(x=delta.theta_norm, fill=..x..), binwidth = 2*pi/nbins, boundary=0, color=color.histline) +
      scale_fill_gradientn(colours = cmap, guide="none")
  }else{
    p <- p + geom_histogram(aes(x=delta.theta_norm, fill=..x..), binwidth = 2*pi/nbins, boundary=0) +
      scale_fill_gradientn(colours = cmap, guide="none")
  }
  
  # set x limit
  p <- p + scale_x_continuous(limits = c(0,2*pi), expand=c(0, 0), breaks = seq(0,2,1/4)*pi) 
  # set y limit
  y.max <- max(ggplot_build(p)$data[[1]]$count)
  p <- p + scale_y_continuous(limits = c(0, y.max*1.3), expand = c(0, 0), breaks = seq(0,y.max,length=4)) 
  
  # move y-zero up  
  #p <- p + scale_y_continuous(limits = c(-.2*y.max, y.max*1.3), expand = c(0, 0), breaks = seq(0,y.max,length=4)) 
  #p <- p + geom_segment(aes(x = x,y = 0,xend = x,yend = 0), 
  #                      data=data.frame(x = seq(0,2,1/4)*pi),linetype = "solid",color = "gray90")
  
  # set reference line (delta.ICC=0 or optimal)
  p <- p + geom_segment(aes(x = x,y = 0,xend = x,yend = y.max), 
                        data=data.frame(x = seq(0,2,1/2)*pi),linetype = "dashed",color = "gray10")
  p <- p + geom_segment(aes(x = x,y = 0,xend = x,yend = y.max*1.05), 
                        data=data.frame(x = seq(1/4,2,1/2)*pi),linetype = "solid",color = "black")
  # add reference arrow (delta.ICC = optimal)
  p <- p + 
    geom_line(aes(x=x, y=y), data=data.frame(x=c(.75*pi, .75*pi), y=c(y.max*1.05, y.max)),
                     arrow = arrow(length=unit(0.30,"cm"), ends="first", type = "closed")) + 
    geom_line(aes(x=x, y=y), data=data.frame(x=c(1.75*pi, 1.75*pi), y=c(y.max*1.05, y.max)),
              arrow = arrow(length=unit(0.30,"cm"), ends="first", type = "closed")) 
  
  if (show.ytick){
    # set y grid
    y.tick <- seq(0,y.max,length=4)
    p <- p + geom_hline(aes(yintercept = y), data.frame(y = y.tick), color = "lightgrey") +
      annotate(geom="text", x=0.6*pi, y=y.tick[2], label=sprintf('%.0f',y.tick[2]), color="gray50", angle='18') +
      annotate(geom="text", x=0.6*pi, y=y.tick[3], label=sprintf('%.0f',y.tick[3]), color="gray50", angle='18') +
      annotate(geom="text", x=0.6*pi, y=y.tick[4], label=sprintf('%.0f',y.tick[4]), color="gray50", angle='18')
  }
  
  # add gradient ref legend
  if (show.ref.legend){
    p <- p + 
      annotate(geom="text", x=0.25*pi, y=y.max*1.3, label='paste(Delta, "ICC=0")', color="gray10", angle='45',parse=TRUE)+
      annotate(geom="text", x=1.25*pi, y=y.max*1.3, label='paste(Delta, "ICC=0")', color="gray10", angle='45',parse=TRUE)+
      annotate(geom="text", x=0.74*pi, y=y.max*1.3, label='paste(Delta, "ICC>0")', color="gray10", angle='315',parse=TRUE)+
      annotate(geom="text", x=0.77*pi, y=y.max*1.3, label='paste("Optimal")', color="gray10", angle='315', parse=TRUE)+
      annotate(geom="text", x=1.74*pi, y=y.max*1.3, label='paste("Optimal")', color="gray10", angle='315',parse=TRUE)+
      annotate(geom="text", x=1.77*pi, y=y.max*1.3, label='paste(Delta, "ICC<0")', color="gray10", angle='315', parse=TRUE)
      
  }
  # show title
  if (!is.null(plot.title)){
    p <- p + ggtitle(plot.title)
  }
  # set theme
  p <- p + 
    theme(plot.title = element_text(hjust = 0.5),
          axis.title = element_blank(), axis.ticks = element_blank(),
          axis.text.y = element_blank(), axis.text.x = element_blank(),
          plot.background = element_blank(), 
          panel.background = element_rect(fill = "white", color = "white"),
          panel.grid = element_blank())
  
  return(p)
}

