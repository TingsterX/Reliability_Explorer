
## run ICC model in R
proj_dir=/home/txu/projects/Xu_2021_reliability_field_map
in_dir=${proj_dir}/results_HNU/ROI_Schaefer200/icc_input_csv
out_dir=${proj_dir}/results_HNU/ROI_Schaefer200/rex_icc
mkdir -p ${out_dir}
# cat pipelines.list | parallel 
#pipelines="cpac_default_all cpac_default_all_gsr cpac_fmriprep_all cpac_fmriprep_all_gsr cpac_ccs_all cpac_ccs_all_gsr cpac_abcd_all cpac_abcd_all_gsr"
pipelines=$1

for pipeline in $pipelines; do
  echo $pipeline
  docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_calc.R \
    -i ${in_dir}/${pipeline}_2subsets_10min.csv \
    -u ICC1 \
    -m All \
    -d 3:19902 \
    -s subID \
    -r visit \
    -o ${out_dir}/${pipeline}_2subsets_10min
done

for pipeline in $pipelines; do
  echo $pipeline
  docker run --rm -v /home/txu:/home/txu tingsterx/rex:v1.0.1 rex_command_calc.R \
    -i ${in_dir}/${pipeline}_2subsets_30min.csv \
    -u ICC1 \
    -m All \
    -d 3:19902 \
    -s subID \
    -r visit \
    -o ${out_dir}/${pipeline}_2subsets_30min
done