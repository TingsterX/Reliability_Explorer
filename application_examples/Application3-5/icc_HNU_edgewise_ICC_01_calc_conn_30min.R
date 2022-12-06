library(data.table)

# original data directory: lisa/ned /data3/cnl/fmriprep/Lei_working/Finalizing/All_sessions_new/ROI/ROI_Schaefer200
# proj_dir <- '/data3/cdb/txu/projects/Xu_2021_reliability_field_map' # @lisa/ned
proj_dir <- '/home/txu/projects/Xu_2021_reliability_field_map'
setwd(file.path(proj_dir, 'scripts/_pipeline_comp'))

data_dir <- file.path(proj_dir, 'data_cpac_NHU/ROI_Schaefer200')
out_dir <- paste0(proj_dir, '/results_HNU/ROI_Schaefer200/icc_input_csv')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Parcel Schaefer200
Nconn <- 200*199/2

pipelines <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all/cpac_fmriprep_all_v2", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")
pnames <- c("cpac_default_all", "cpac_default_all_gsr", "cpac_fmriprep_all", "cpac_fmriprep_all_gsr", "cpac_ccs_all", "cpac_ccs_all_gsr", "cpac_abcd_all", "cpac_abcd_all_gsr")
subjects <- scan("subjects_HNU.list", what="", sep="\n")
sessions <- scan("sessions.list", what="", sep="\n")
nrow <- length(subjects)*2


for (p in 1:length(pipelines)){
    fout <- paste0(out_dir, '/', pnames[p], '_2subsets_30min.csv')
    print(sprintf('generate csv: %s\n', fout))
    df <- data.frame(matrix(NA, nrow=nrow, ncol=Nconn))
    df.id <- data.frame(subID = matrix(NA, nrow=nrow, ncol=1), visit = matrix(NA, nrow=nrow, ncol=1))
    rowi <- 1
    for (s in 1:length(subjects)){
        cat(sprintf('->%d: %s', s, subjects[s]))
        # session1
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[1], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts1 <- ts[,2:dim(ts)[2]]; ts1 <- scale(ts1)
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[2], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts2 <- ts[,2:dim(ts)[2]]; ts2 <- scale(ts2)
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[3], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts3 <- ts[,2:dim(ts)[2]]; ts3 <- scale(ts3)
        ts <- rbind(ts1, ts2, ts3)

        conn <- cor(ts)
        conn <- conn[upper.tri(conn)]
        df[rowi,] <- conn
        df.id$subID[rowi] <- subjects[s]
        df.id$visit[rowi] <- 'abc'
        rowi <- rowi + 1
        # session2
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[5], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts1 <- ts[,2:dim(ts)[2]]; ts1 <- scale(ts1)
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[6], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts2 <- ts[,2:dim(ts)[2]]; ts2 <- scale(ts2)
        fname <- paste0(data_dir, '/', pipelines[p], '/', subjects[s], sessions[7], '.1D')
        ts <- fread(fname, sep="\t", data.table=FALSE)
        ts3 <- ts[,2:dim(ts)[2]]; ts3 <- scale(ts3)
        ts <- rbind(ts1, ts2, ts3)

        conn <- cor(ts)
        conn <- conn[upper.tri(conn)]
        df[rowi,] <- conn
        df.id$subID[rowi] <- subjects[s]
        df.id$visit[rowi] <- 'fgh'
        rowi <- rowi + 1
    }
    df <- cbind(df.id, df)
    # write
    print('write the dataframe into csv file')
    fwrite(df, fout)
}

