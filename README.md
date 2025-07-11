# CPS-TUS Import and Cleaning for Stata, 2014-2023

These files are designed to import and clean the Current Population Survey's Tobacco Use Supplement (CPS-TUS) data from 2014-2023 using Stata. The data files and code from the US Census Bureau are available at [https://www.census.gov/data/datasets/time-series/demo/cps/cps-supp_cps-repwgt/cps-tobacco.html](https://www.census.gov/data/datasets/time-series/demo/cps/cps-supp_cps-repwgt/cps-tobacco.html). However, the code available is only in SAS. This repository contains adapted versions of that Census Bureau code, focusing on self-respondents. Import files are provided for each wave, along with a combined self-respondent replicate weight file. Labels in the label files are drawn directly from the Census Bureau, so users may want to truncate them for readability. 

A harmonized version of the CPS-TUS is available from the National Cancer Institute:

`National Cancer Institute. (2025). Tobacco Use Supplement to the Current Population Survey Harmonized Data, 1992-2023. cancercontrol.cancer.gov/brp/tcrb/tus-cps/`

However, this harmonized data does not presently include some of the flavor variables for cigars and electronic nicotine delivery systems (ENDS) found in the 2018-2019 and 2022-2023 waves. 

The CPS is also available in a harmonized form from IPUMS at [https://cps.ipums.org/cps/](https://cps.ipums.org/cps/). 


## Author
Reginald B. Hebert, Yale University
11 July 2025

**Original SAS code by US Census Bureau**
**Data labeling conventions adapted from NCI**
