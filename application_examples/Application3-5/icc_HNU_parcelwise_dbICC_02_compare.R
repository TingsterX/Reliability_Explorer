library(data.table)
library(ReX)

# original data directory: lisa/ned /data3/cnl/fmriprep/Lei_working/Finalizing/All_sessions_new/ROI/ROI_Schaefer200
#proj_dir <- '/data3/cdb/txu/projects/Xu_2021_reliability_field_map' # @lisa/ned
proj_dir <- '/home/txu/projects/Xu_2021_reliability_field_map'
setwd(file.path(proj_dir, 'scripts/_pipeline_comp'))

data_dir <- file.path(proj_dir, 'data_cpac_NHU/ROI_Schaefer200')
out_dir <- paste0(proj_dir, '/results_cpac_HNU/ROI_Schaefer200/rex_dbICC_per_parcel')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Parcel Schaefer200
Nparcel <- 200

pipelines <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all/cpac_fmriprep_all_v2", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")
pnames <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")


for (amount in c("10min", "30min")){
  
  df.out <- data.frame()
  for (p1 in 1:length(pipelines)){
    fname <- paste0(out_dir, '/dbICC_parcelwise_', pnames[p1], '_2subsets_', amount ,'.csv')
    df1 <- fread(fname)
    for (p2 in 1:length(pipelines)){
      fname <- paste0(out_dir, '/dbICC_parcelwise_', pnames[p2], '_2subsets_', amount ,'.csv')
      df2 <- fread(fname)
      
      if (p1 != p2){
        a1 <- stringr::str_replace(pnames[p1], '_gsr', '')
        a2 <- stringr::str_replace(pnames[p2], '_gsr', '')
        b1 <- grepl("gsr", pnames[p1])
        b2 <- grepl("gsr", pnames[p2])
        # same pipeline (gsr vs nogsr) or (not the same pipeline, both gsr or both no-gsr)
        if  ( (a1 == a2) || ((a1!=a2) && b1 && b2) || ((a1!=a2) && !b1 && !b2)) {
          print(sprintf('compare %s and %s\n', pnames[p1], pnames[p2]))
          df_VarPairedComp <- icc_gradient_flow(df1$var_w, df1$var_b, df2$var_w, df2$var_b)
          df_VarPairedComp$parcel <- c(1:Nparcel)
          df_VarPairedComp$contrast <- sprintf('%s__CompTo__%s', pnames[p1], pnames[p2])

          if (a1==a2){
            df_VarPairedComp$comp <- 'compare_GSR'
          } else{
            df_VarPairedComp$comp <- 'compare_pipeline'
          }
          
          df.out <- rbind(df.out, df_VarPairedComp)
        }
      }
    }
  }
  # write
  print('write the dataframe into csv file')
  fout <- paste0(out_dir, '/dbICC_parcelwise_pipeines_comp_', amount ,'.csv')
  fwrite(df.out, fout)
  
}

# 30min vs 10min
df.out <- data.frame()
for (p in 1:length(pipelines)){
    fname <- paste0(out_dir, '/dbICC_parcelwise_', pnames[p], '_2subsets_30min.csv')
    df1 <- fread(fname)
    
    fname <- paste0(out_dir, '/dbICC_parcelwise_', pnames[p], '_2subsets_10min.csv')
    df2 <- fread(fname)
    
    print(sprintf('30min vs 10min: %s\n', pnames[p]))
    df_VarPairedComp <- icc_gradient_flow(df1$var_w, df1$var_b, df2$var_w, df2$var_b)
    df_VarPairedComp$parcel <- c(1:Nparcel)
    df_VarPairedComp$contrast <- sprintf('30min_10min_%s', pnames[p])
    df_VarPairedComp$comp <- '30min_10min'
    df.out <- rbind(df.out, df_VarPairedComp)
}
# write
print('write the dataframe into csv file')
fout <- paste0(out_dir, '/dbICC_parcelwise_compare_30min_10min.csv')
fwrite(df.out, fout)

