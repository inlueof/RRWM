# README: GSS 2017 Life Satisfaction Analysis  

## Project Overview  
This project uses data from the **2017 Canadian General Social Survey (GSS)** to examine whether **household income, education, religious attendance, and gender** predict **self-rated life satisfaction** (0–10 scale).  

Analyses were conducted in **R 4.5.1** within **RStudio 2025.09.0 Build 387 (“Cucumberleaf Sunflower”)**, using survey weights and bootstrap replicate weights to account for complex sampling design.  

---

## Research Question  
Does household income, education, religious attendance, and gender predict self-rated life satisfaction in Canada?  

---

## Dataset  
- Source: **Statistics Canada, General Social Survey (2017)**  
- File used: `gss-12M0025-E-2017-c-31_F1.csv`  
- Outcome variable: `SLM_01` (Life satisfaction, 0–10 scale)  
- Predictors:  
  - `FAMINCG2` (Household income)  
  - `EHG3_01B` (Highest education)  
  - `REE_03` (Religious attendance)  
  - `SEX` (Gender)  
- Weights:  
  - `WGHT_PER` (Person weight)  
  - `WTBS_001` … `WTBS_500` (Bootstrap replicate weights)  

---

## Software and Packages  
- **RStudio:** 2025.09.0 Build 387 (Windows 10)  
- **R:** 4.5.1 (2025-06-13 ucrt)  
- **Quarto:** 1.7.32  
- **Packages used:**  
  - `tidyverse` (ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats)  
  - `survey` (svyglm, svrepdesign, svymean, svyvar)  
  - `broom` (tidy regression outputs)  

---

## Workflow  

1. **Load raw dataset** into R using `read_csv()`.  
2. **Unweighted counts** examined for life satisfaction, income, education, religion, and gender (including missing codes).  
3. **Clean and recode variables**:  
   - Life satisfaction (SLM_01): coded 0–10, excluded special codes (96–99).  
   - Income (FAMINCG2): recoded into six categories.  
   - Education (EHG3_01B): recoded into seven categories.  
   - Religious attendance (REE_03): recoded into six categories.  
   - Gender (SEX): recoded into Male/Female.  
   - All cases with missing data dropped.  
   - Final unweighted N = **19,772**.  
4. **Define survey design** using `svrepdesign()` with WGHT_PER and WTBS replicate weights.  
5. **Weighted descriptives (Table 1)**:  
   - Weighted mean (SD) of life satisfaction.  
   - Weighted proportions and 95% CI for categorical predictors.  
6. **Regression models**:  
   - **Bivariate model:** Life satisfaction ~ Income.  
   - **Multivariate model:** Life satisfaction ~ Income + Education + Religion + Gender.  
   - Survey-weighted linear regression using `svyglm()`.  
   - Extracted coefficients, SEs, t, and p-values, formatted in APA tables (Tables 2 & 3).  
7. **Save outputs**:  
   - Cleaned dataset saved as `2017_GSS_recode.Rds`.  
   - Models saved as `2017_GSS_models.Rds`.  

---

## Tables  

- **Table 1**: Weighted descriptive statistics (income, education, religion, gender).  
- **Table 2**: Bivariate regression (Life satisfaction ~ Income).  
- **Table 3**: Multivariate regression (Life satisfaction ~ Income + Education + Religion + Gender).  

---

## Notes  
- Intercept represents the predicted mean for the reference group: *Income < $25k, Education = HS diploma, Religion = Not at all, Gender = Male.*  
- Reference categories listed in table notes; not included as coefficient rows.  
- Wald tests used to assess overall predictor significance.  
- No *R²* reported; emphasis is on survey-adjusted coefficients and F-tests.  


## Data 

Data used in this exercise were obtained through ODESI, a service provided by the Ontario Council of University Libraries (https://search1.odesi.ca/#/

Links to an external site.).

Access is restricted to those users who have a DLI License and can be used for statistical and research purposes. The terms and more information about the license can be viewed here (https://www.statcan.gc.ca/en/microdata/dli

Links to an external site.).

As part of McGill University, the CAnD3 initiative has a license to use the data for the purposes of training. Those outside of McGill university should not use the data provided through CAnD3's training activities for purposes not related to their CAnD3 training.

Fellows who belong to another DLI institution should re-download the data using the ODESI site using the login provided by their institution if they wish to make use of the data for other purposes.


## Data Citation

Statistics Canada. 2020. General Social Survey, Cycle 31, 2017 [Canada]: Family (version 2020-09). Statistics Canada [producer and distributor], accessed September 10, 2021. ID: gss-12M0025-E-2017-c-31