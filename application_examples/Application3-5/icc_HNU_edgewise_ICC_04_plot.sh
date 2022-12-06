
## run ICC model in R
proj_dir=/home/txu/projects/Xu_2021_reliability_field_map
icc_dir=${proj_dir}/results_HNU/ROI_Schaefer200/rex_icc
out_dir=${proj_dir}/results_HNU/ROI_Schaefer200/rex_icc_plotN
mkdir -p ${out_dir}

# All Pipeline
pipelines="cpac_fmriprep_all cpac_ccs_all cpac_abcd_all"
# nogsr - 10min
list="${icc_dir}/cpac_default_all_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
for pipeline in $pipelines; do
  list="${list},${icc_dir}/${pipeline}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
done
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label cpac,fmriprep,ccs,abcd \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/NOGSR_10min_AllPipelines
# gsr - 10min
list="${icc_dir}/cpac_default_all_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
for pipeline in $pipelines; do
  list="${list},${icc_dir}/${pipeline}_gsr_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
done
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label cpac,fmriprep,ccs,abcd \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/GSR_10min_AllPipelines
# nogsr - 30min
list="${icc_dir}/cpac_default_all_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
for pipeline in $pipelines; do
  list="${list},${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv"
done
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label cpac,fmriprep,ccs,abcd \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/NOGSR_30min_AllPipelines
# gsr - 30min
list="${icc_dir}/cpac_default_all_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
for pipeline in $pipelines; do
  list="${list},${icc_dir}/${pipeline}_gsr_2subsets_30min_ReX_Univariate_ICC_1wayR.csv"
done
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label cpac,fmriprep,ccs,abcd \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/GSR_30min_AllPipelines

# 10min and 30min
pipelines="cpac_default_all cpac_fmriprep_all cpac_ccs_all cpac_abcd_all"
for pipeline in $pipelines; do
list="${icc_dir}/${pipeline}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv,${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv"
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label 10min,30min \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/${pipeline}_10min_30min
done

for pipeline in $pipelines; do
list="${icc_dir}/${pipeline}_gsr_2subsets_10min_ReX_Univariate_ICC_1wayR.csv,${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv"
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label 10min,30min \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/${pipeline}_gsr_10min_30min
done

# gsr and nogsr
pipelines="cpac_default_all cpac_fmriprep_all cpac_ccs_all cpac_abcd_all"
for pipeline in $pipelines; do
list="${icc_dir}/${pipeline}_2subsets_10min_ReX_Univariate_ICC_1wayR.csv,${icc_dir}/${pipeline}_gsr_2subsets_10min_ReX_Univariate_ICC_1wayR.csv"
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label NOGSR,GSR \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/${pipeline}_10min_NOGSR_GSR
done
for pipeline in $pipelines; do
list="${icc_dir}/${pipeline}_2subsets_30min_ReX_Univariate_ICC_1wayR.csv,${icc_dir}/${pipeline}_gsr_2subsets_30min_ReX_Univariate_ICC_1wayR.csv"
docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_plotN.R \
  --input ${list} \
  --input_label NOGSR,GSR \
  --config_file ${proj_dir}/scripts/_pipeline_comp/rex_config_plotN.txt \
  --out ${out_dir}/${pipeline}_30min_NOGSR_GSR
done

