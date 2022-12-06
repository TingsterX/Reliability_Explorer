Application example 4
================
Ting Xu (github: tingsterx/reliability_explorer)
2022-07-08

### Examine the reliability and individual varition between pipelines with global signal regression (GSR) and without GSR

This application example compares the reliability and individual
varition across four conventional fMRI pipelines including
[fMRIPrep](https://fmriprep.org/en/stable/),
[ABCD](https://www.biorxiv.org/content/10.1101/2021.07.09.451638v1),
[CCS](https://www.sciencedirect.com/science/article/abs/pii/S2095927316305394)
and [C-PAC](https://fcp-indi.github.io/docs/latest/user/index) default.
The details are described in [Li et al.,
2019](https://www.biorxiv.org/content/10.1101/2021.12.01.470790v1)

Raw data: Consortium for Reliability and Reproducibility (CoRR) - [HNU
dataset](http://fcon_1000.projects.nitrc.org/indi/CoRR/html/hnu_1.html)

**Calculation using ReX**: The individual variation, ICC for each edge
(i.e. connectivity), and dbICC at the parcel and whole connectivity
level are calcualted using the code: icc_HNU_edgewise_ICC\_*.R,
icc_HNU_parcelwise_dbICC\_*.R, icc_HNU_AllConn_dbICC\_\*.R

``` r
knitr::opts_chunk$set(warning = FALSE, message = FALSE) 
library(rstudioapi)
library(ReX)
library(ggplot2)
library(data.table)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(ggseg)
library(ggsegSchaefer)
```

### Set path

``` r
setwd(dirname(getSourceEditorContext()$path))
source('func_plot_brain_matrix.R')
```

### compare parcelwise dbICC of GSR vs noGSR across pipelines - 10min

``` r
fname <- paste0(data_dir, "/dbICC_parcelwise_pipelines_10min.csv")
df <- fread(fname)
df <- df %>% dplyr::rename("sigma2_w"="var_w")
df <- df %>% dplyr::rename("sigma2_b"="var_b")

df %>% group_by(pipeline) %>% summarize(mean = mean(dbICC), std = sd(dbICC))
```

    ## # A tibble: 8 × 3
    ##   pipeline               mean    std
    ##   <chr>                 <dbl>  <dbl>
    ## 1 cpac_abcd_all         0.352 0.0672
    ## 2 cpac_abcd_all_gsr     0.395 0.0745
    ## 3 cpac_ccs_all          0.378 0.0692
    ## 4 cpac_ccs_all_gsr      0.415 0.0668
    ## 5 cpac_default_all      0.369 0.0703
    ## 6 cpac_default_all_gsr  0.413 0.0727
    ## 7 cpac_fmriprep_all     0.364 0.0705
    ## 8 cpac_fmriprep_all_gsr 0.418 0.0677

``` r
p <- rex_plot.var.field.n(df, group.name = "pipeline", size.point = 2, color.brewer.pla = "Paired",
                          plot.density=FALSE, show.contour = FALSE, color.point.border = NULL, axis.max=10)
p
```

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
fname <- sprintf('%s/GSR-NOGSR_10min_%s_parcelwise_fieldmap.png', out_dir, prefix)
ggsave(fname, device="png")
```

### compare parcelwise dbICC of GSR vs noGSR across pipelines - 30min

``` r
fname <- paste0(data_dir, "/dbICC_parcelwise_pipelines_30min.csv")
df <- fread(fname)
df <- df %>% dplyr::rename("sigma2_w"="var_w")
df <- df %>% dplyr::rename("sigma2_b"="var_b")

df %>% group_by(pipeline) %>% summarize(mean = mean(dbICC), std = sd(dbICC))
```

    ## # A tibble: 8 × 3
    ##   pipeline               mean    std
    ##   <chr>                 <dbl>  <dbl>
    ## 1 cpac_abcd_all         0.555 0.0608
    ## 2 cpac_abcd_all_gsr     0.664 0.0613
    ## 3 cpac_ccs_all          0.568 0.0576
    ## 4 cpac_ccs_all_gsr      0.695 0.0505
    ## 5 cpac_default_all      0.573 0.0588
    ## 6 cpac_default_all_gsr  0.680 0.0669
    ## 7 cpac_fmriprep_all     0.564 0.0632
    ## 8 cpac_fmriprep_all_gsr 0.678 0.0548

``` r
p <- rex_plot.var.field.n(df, group.name = "pipeline", size.point = 2, color.brewer.pla = "Paired",
                          plot.density=FALSE, show.contour = FALSE, color.point.border = NULL)
p
```

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
fname <- sprintf('%s/GSR-NOGSR_30min_%s_parcelwise_fieldmap.png', out_dir, prefix)
ggsave(fname, device="png")
```

### Comparing pipeline with GSR and without GSR for each of four pipelines (fMRIprep, CCS, ABCD, CPAC) - parcelwise

``` r
data_dir <- file.path('Application3-5', 'results_cpac_HNU', 'ROI_Schaefer200', 'rex_dbICC_per_parcel')
out_dir <- file.path('Application3-5', 'results_cpac_HNU', 'ROI_Schaefer200', 'rex_dbICC_per_parcel_plot')

cmap = ReX::rgb2hex(ReX::colormap.gradient.flow())
atlas <- schaefer7_200$data
labels <- read.table(file.path('Application3-5', 'atlas', 'Schaefer2018_200Parcels_7Networks_labels_MatchedTo_ggseg.txt'), header = TRUE)[,1]

pipeline_list <- c("cpac_default_all", "cpac_fmriprep_all", "cpac_ccs_all", "cpac_abcd_all")

for (amount in c("10min", "30min")){
  fname <- paste0(data_dir, "/dbICC_parcelwise_pipeines_comp_", amount, ".csv")
  df_all <- fread(fname)
  
  for (pipeline in pipeline_list){
    prefix <- sprintf('%s_gsr__CompTo__%s', pipeline, pipeline)
  
    df <- df_all %>% filter(contrast == prefix)
    df4ggseg <-  tibble(region = labels, data=df$delta.theta_norm)
    
    p <- df4ggseg %>% 
    ggseg(mapping = aes(fill = data), atlas=schaefer7_200, position="stacked") +
      scale_fill_gradientn(colours = cmap, limits= c(0, 2*pi)) +
      guides(fill = guide_colorbar(barheight=5)) +
      labs(fill = "normalized changes") + annotate(geom="text",label=NULL)
    print(sprintf('%s: %s', amount, prefix))
    print(p)
    fname <- sprintf('%s/GSR-NOGSR_%s_%s_parcelwise.png', out_dir, amount, prefix)
    ggsave(fname, device="png")
      
  }
  
}
```

    ## [1] "10min: cpac_default_all_gsr__CompTo__cpac_default_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

    ## [1] "10min: cpac_fmriprep_all_gsr__CompTo__cpac_fmriprep_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-2.png)<!-- -->

    ## [1] "10min: cpac_ccs_all_gsr__CompTo__cpac_ccs_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-3.png)<!-- -->

    ## [1] "10min: cpac_abcd_all_gsr__CompTo__cpac_abcd_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-4.png)<!-- -->

    ## [1] "30min: cpac_default_all_gsr__CompTo__cpac_default_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-5.png)<!-- -->

    ## [1] "30min: cpac_fmriprep_all_gsr__CompTo__cpac_fmriprep_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-6.png)<!-- -->

    ## [1] "30min: cpac_ccs_all_gsr__CompTo__cpac_ccs_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-7.png)<!-- -->

    ## [1] "30min: cpac_abcd_all_gsr__CompTo__cpac_abcd_all"

![](Application4_plot_parcelwise_files/figure-gfm/unnamed-chunk-1-8.png)<!-- -->
