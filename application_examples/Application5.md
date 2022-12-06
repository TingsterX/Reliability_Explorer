Application example 5
================
Ting Xu (github: tingsterx/reliability_explorer)
2022-07-08

### Examine the reliability and individual varition of 30 min vs 10 min data

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

----

30min vs 10min: cpac_default_all

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_default_all_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_default_all_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_default_all_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_fmriprep_all

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_fmriprep_all_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_fmriprep_all_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_fmriprep_all_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_ccs_all

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_ccs_all_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_ccs_all_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_ccs_all_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_abcd_all

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_abcd_all_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_abcd_all_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_abcd_all_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_default_all_gsr

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_default_all_gsr_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_default_all_gsr_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_default_all_gsr_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_fmriprep_all_gsr

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_fmriprep_all_gsr_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_fmriprep_all_gsr_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_fmriprep_all_gsr_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_ccs_all_gsr

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_ccs_all_gsr_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_ccs_all_gsr_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_ccs_all_gsr_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)

30min vs 10min: cpac_abcd_all_gsr

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_plotN/cpac_abcd_all_gsr_10min_30min.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_abcd_all_gsr_ReX_CompareICC_ChangeOfVariation_Raw.png)

![](Application3-5/results_cpac_HNU/ROI_Schaefer200/rex_icc_comp/30min-10min_cpac_abcd_all_gsr_ReX_CompareICC_ChangeOfVariation_Normalized_GradientFlow.png)
