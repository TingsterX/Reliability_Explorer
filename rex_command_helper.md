## Reliability Explorer (ReX) 
This is the command line version of ReX which includes the following relabition calculation and plotting functions

Calculate and plot reliability and individual variation, see help for each function:

```
  docker run --rm tingsterx:rex rex_command_calc.R
  docker run --rm tingsterx:rex rex_command_plot.R
  docker run --rm tingsterx:rex rex_command_plotN.R
```

Compare reliability and individual variation, see help see help for each function:
```
  docker run --rm tingsterx:rex rex_command_comp.R
  docker run --rm tingsterx:rex rex_command_plotC.R
```

----
### Demo: rex_command_calc.R
 ```
  docker run --rm \ 
       -v /local/path/to/a/folder:/output \ 
       tingsterx/rex rex_command_calc.R \ 
       -i demo_data.csv \ 
       -u ICC1 \ 
       -m All \ 
       -d 5:364 \ 
       -s subID \ 
       -r visit \ 
       -c age,gender\ 
       -o /output/demo_rex_calc \ 
       [optional arguments]
```
  Optional arguments see help message:
       docker run --rm tingsterx:rex rex_command_calc.R

  The outputs are saved in /local/path/to/a/folder 


### Demo: rex_command_comp.R
 ```
  docker run --rm \ 
       -v /local/path/to/a/folder:/output \ 
       tingsterx/rex rex_command_comp.R \ 
       --baseline icc_output_Data1.csv \ 
       --target icc_output_Data2.csv \ 
       --base_name Data1 \ 
       --target_name Data2 \ 
       --base_w sigma2_w \ 
       --base_b sigma2_b \ 
       --target_w sigma2_b \ 
       --target_b sigma2_b \ 
       --out /output/demo_rex_comp 
       [optional arguments]
```
  Optional arguments see help message:
       docker run --rm tingsterx:rex rex_command_comp.R

  The outputs are saved in /local/path/to/a/folder 


### Demo: rex_command_plot.R
 ```
  docker run --rm \ 
       -v /local/path/to/a/folder:/output \ 
       tingsterx/rex rex_command_plot.R \ 
       --input icc_output_Data1.csv \ 
       --config_file rex_command_plot.txt \ 
       -o /output/demo_rex_plot \ 
       [optional arguments]
```
  Optional arguments see help message:
       docker run --rm tingsterx:rex rex_command_plot.R


### Demo: rex_command_plotN.R
 ```
  docker run --rm \ 
       -v /local/path/to/a/folder:/output \ 
       tingsterx/rex rex_command_plotN.R \ 
       --input icc_output_Data1.csv，icc_output_Data2.csv \ 
       --config_file rex_command_plotN.txt \ 
       -o /output/demo_rex_plotN \ 
       [optional arguments]
```
  Optional arguments see help message:
       docker run --rm tingsterx:rex rex_command_plotN.R


### Demo: rex_command_plotC.R
 ```
  docker run --rm \ 
       -v /local/path/to/a/folder:/output \ 
       tingsterx/rex rex_command_plotC.R \ 
       --input CompareICC_Results.csv \ 
       --plot norm \ 
       --config_file rex_configure_plotC_norm.txt \ 
       -o /output/demo_rex_plotC \ 
       [optional arguments]
```
  Optional arguments see help message:
       docker run --rm tingsterx:rex rex_command_plotC.R

----
Demo data is also enclosed: https://github.com/TingsterX/Reliability_Explorer/demo_data
