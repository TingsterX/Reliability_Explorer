
## Welcome to **Reliability Explorer (ReX)**

----

**Reliability Explorer** (ReX) is an online shiny app (https://tingsterx.shinyapps.io/ReliabilityExplorer) for  calculating reliability and mapping individual variations of neuroimaging and behavioral data to facilitate the assessment of reliability and reproducibility in neuroscience and psychology. This toolbox provides two modules. 

1. **"Calculate Your Data"** module. This module implements parametric and nonparametric methods for univariate and multivariate reliability calculation including Intraclass correlation ([ICC](https://github.com/TingsterX/Reliability_Explorer/blob/main/tutorial_ICC_in_R.ipynb)), distance-based ICC (dbICC), Image Intraclass Correlation Coefficient (I2C2), discriminability, and identification rate (i.e. fingerprinting). The results will be presented in a two-dimensional individual variation space (see "ICC and Variation Field") to facilitate understanding of individual difference and its relation to reliability assessment. In addition, this module also provides the interactive visualization module for inspecting data and results. It will help to detect (1) which variable of interest has low reliablity, (2) which observation is a potential outliers. 

2. **"Compare Results (Individual Variation & Gradient Flow)"** module will build a pair-wise comparison of intraclass correlation and its component variations (within- and between-individual variations). The gradient flow map provides the normalized change of the ICC as compared to the most efficient direction for improving ICC, which helps to guide optimization efforts for measurement of individual differences.

----

### Run **Reliability Explorer (ReX)** locally using Docker


#### Install docker

https://docs.docker.com/get-docker/

#### Pull docker image

```
docker push tingsterx/reliability_explorer
```

#### Run docker
```
docker run --rm -p 3838:3838 tingsterx/reliability_explorer
```

#### Launch **ReX**

Open a web browser (e.g. Chrome), visit http://localhost:3838/rex

#### Note
R version: 4.1.0 (2021-05-18)

----

#### When using “Reliability Explorer”, please cite the following manuscript:

- T Xu. J W Cho, G Kiar, E W. Bridgeford, J T. Vogelstein, M P. Milham. A Guide for Quantifying and Optimizing Measurement Reliability for the Study of Individual Differences. (doi: https://doi.org/10.1101/2022.01.27.478100)


