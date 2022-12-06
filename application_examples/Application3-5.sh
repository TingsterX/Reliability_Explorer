## run ICC model in R - Comparing fMRI pipelines  (Application 3, 4, 5)

proj_dir=/home/txu/projects/Xu_2021_reliability_field_map
icc_dir=${proj_dir}/results_cpac_HNU/ROI_Schaefer200/rex_icc
out_dir=${proj_dir}/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp
mkdir -p ${out_dir}


## Application 3
# Pipeline comparison (NoGSR)
pipelines="cpac_default_all cpac_fmriprep_all cpac_ccs_all cpac_abcd_all"
# 10min
for pipeline1 in $pipelines; do
  for pipeline2 in $pipelines; do
    docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
      --baseline ${icc_dir}/${pipeline1}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
      --target ${icc_dir}/${pipeline2}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
      --base_name ${pipeline1} \
      --target_name ${pipeline2} \
      --out ${out_dir}/PipelineComp10min_${pipeline1}-${pipeline2}
  done
done
# 30min
for pipeline1 in $pipelines; do
  for pipeline2 in $pipelines; do
    docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
      --baseline ${icc_dir}/${pipeline1}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
      --target ${icc_dir}/${pipeline2}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
      --base_name ${pipeline1} \
      --target_name ${pipeline2} \
      --out ${out_dir}/PipelineComp30min_${pipeline1}-${pipeline2}
  done
done

# Pipeline comparison (GSR)
pipelines="cpac_default_all_gsr cpac_fmriprep_all_gsr cpac_ccs_all_gsr cpac_abcd_all_gsr"
# 10min
for pipeline1 in $pipelines; do
  for pipeline2 in $pipelines; do
    if [ ${pipeline1} != ${pipeline2} ]; then
    docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
      --baseline ${icc_dir}/${pipeline1}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
      --target ${icc_dir}/${pipeline2}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
      --base_name ${pipeline1} \
      --target_name ${pipeline2} \
      --out ${out_dir}/PipelineComp10min_${pipeline1}-${pipeline2}
    fi
  done
done
# 30min
for pipeline1 in $pipelines; do
  for pipeline2 in $pipelines; do
    if [ ${pipeline1} != ${pipeline2} ]; then
    docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
      --baseline ${icc_dir}/${pipeline1}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
      --target ${icc_dir}/${pipeline2}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
      --base_name ${pipeline1} \
      --target_name ${pipeline2} \
      --out ${out_dir}/PipelineComp30min_${pipeline1}-${pipeline2}
    fi
  done
done


## Application 4
# gsr vs nogsr(baseline)
pipelines="cpac_default_all cpac_fmriprep_all cpac_ccs_all cpac_abcd_all"
# 10min
for pipeline in $pipelines; do
  echo $pipeline
  docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
    --baseline ${icc_dir}/${pipeline}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
    --target ${icc_dir}/${pipeline}_gsr_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
    --base_name NOGSR \
    --target_name GSR \
    --out ${out_dir}/GSR-NOGSR_10min_${pipeline}
done
# 30min
for pipeline in $pipelines; do
  echo $pipeline
  docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
    --baseline ${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
    --target ${icc_dir}/${pipeline}_gsr_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
    --base_name NOGSR \
    --target_name GSR \
    --out ${out_dir}/GSR-NOGSR_30min_${pipeline}
done


## Application 5
# 30 min vs 10min(baseline)
pipelines="cpac_default_all cpac_default_all_gsr cpac_fmriprep_all cpac_fmriprep_all_gsr cpac_ccs_all cpac_ccs_all_gsr cpac_abcd_all cpac_abcd_all_gsr"
for pipeline in $pipelines; do
  echo $pipeline
  docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_comp.R \
    --baseline ${icc_dir}/${pipeline}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv \
    --target ${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv \
    --base_name 10min \
    --target_name 30min \
    --out ${out_dir}/30min-10min_${pipeline}
done
