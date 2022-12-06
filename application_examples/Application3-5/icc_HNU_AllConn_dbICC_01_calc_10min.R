library(data.table)
library(ReX)

# original data directory: lisa/ned /data3/cnl/fmriprep/Lei_working/Finalizing/All_sessions_new/ROI/ROI_Schaefer200
# proj_dir <- '/data3/cdb/txu/projects/Xu_2021_reliability_field_map' # @lisa/ned
proj_dir <- '/home/txu/projects/Xu_2021_reliability_field_map'
setwd(file.path(proj_dir, 'scripts/_pipeline_comp'))

data_dir <- file.path(proj_dir, 'data_cpac_NHU/ROI_Schaefer200')
out_dir <- paste0(proj_dir, '/results_cpac_HNU/ROI_Schaefer200/rex_dbICC_all_conn')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Parcel Schaefer200
Nconn <- 200*199/2

pipelines <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all/cpac_fmriprep_all_v2", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")
pnames <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")
subjects <- scan("subjects_HNU.list", what="", sep="\n")
sessions <- scan("sessions.list", what="", sep="\n")
nrow <- length(subjects)*2



amount <- "10min"


for (p in 1:length(pipelines)){
    fout <- paste0(out_dir, '/', pnames[p], '_2subsets_', amount ,'.csv')
    print(sprintf('generate csv: %s\n', fout))
    
    conn_all <- array(0, c(nrow, Nconn))
    df.id <- data.frame(subID = matrix(NA, nrow=nrow, ncol=1), visit = matrix(NA, nrow=nrow, ncol=1))
    rowi <- 1
    for (s in 1:length(subjects)){
        cat(sprintf('->%d: %s', s, subjects[s]))
        # session1
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[1], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts <- ts[,2:dim(ts)[2]]
        
        conn <- cor(ts)
        conn <- conn[upper.tri(conn)]
        conn_all[rowi,] <- conn
        df.id$subID[rowi] <- subjects[s]
        df.id$visit[rowi] <- sessions[1]
        rowi <- rowi + 1
        
        # session2
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[6], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts <- ts[,2:dim(ts)[2]]
        
        conn <- cor(ts)
        conn <- conn[upper.tri(conn)]
        conn_all[rowi,] <- conn
        df.id$subID[rowi] <- subjects[s]
        df.id$visit[rowi] <- sessions[6]
        rowi <- rowi + 1
    }
    
    
    Dmax <- dist(conn_all, method = "euclidean")
    out.dbicc <- ReX::calc_dbICC(Dmax, df.id$subID)
    df <- data.frame(dbICC=out.dbicc$dbicc, var_w=out.dbicc$var_w, var_b=out.dbicc$var_b, row.names = pnames[p])
   
    # write
    print('write the dataframe into csv file')
    fout <- paste0(out_dir, '/dbICC_allconn_', pnames[p], '_2subsets_', amount ,'.csv')
    fwrite(df, fout)
}

# merge icc
df.out <- data.frame()
for (p in 1:length(pipelines)){
    fname <- paste0(out_dir, '/dbICC_allconn_', pnames[p], '_2subsets_', amount ,'.csv')
    df <- fread(fname)
    df$pipeline <- pnames[p]
    df.out <- rbind(df.out, df)
}
print('write the dataframe into csv file')
fout <- paste0(out_dir, '/dbICC_allconn_pipelines_', amount ,'.csv')
fwrite(df.out, fout)

