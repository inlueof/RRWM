# 1. ---- load packages ----
library(tidyverse)
library(survey)

# 2. ---- load dataset ----

gss <- read_csv("gss-12M0025-E-2017-c-31_F1.csv")

# 3. ---- look at counts ----

cat("\n--- Unweighted counts BEFORE cleaning ---\n")
print(table(gss$SLM_01, useNA = "ifany"))     # life satisfaction (0-10 + special codes)
print(table(gss$FAMINCG2, useNA = "ifany"))   # income 
print(table(gss$EHG3_01B, useNA = "ifany"))   # education
print(table(gss$REE_03, useNA = "ifany"))     # religious attendance
print(table(gss$SEX, useNA = "ifany"))        # gender (1=Male, 2=Female)

# 3. ---- remove non-responses/valid skips ----
na_sentry <- function(x, bad = c(96,97,98,99)) {
  if (is.factor(x)) x <- as.numeric(as.character(x))
  if (is.character(x)) x <- suppressWarnings(as.numeric(x))
  x[x %in% bad] <- NA
  x
}


# 4. ---- cleaned dataset with recoded variables ----
dat_clean <- gss %>%
  select(SLM_01, FAMINCG2, EHG3_01B, REE_03, SEX,    
         WGHT_PER, starts_with("WTBS_")) %>%
  mutate(
    SLM_01   = na_sentry(SLM_01),
    FAMINCG2 = na_sentry(FAMINCG2),
    EHG3_01B = na_sentry(EHG3_01B),
    REE_03   = na_sentry(REE_03),
    SEX      = na_sentry(SEX),
    SLM_01   = as.numeric(SLM_01),
    FAMINCG2 = factor(FAMINCG2, levels = 1:6,
                      labels = c("< $25k", "$25–49,999", "$50–74,999",
                                 "$75–99,999", "$100–124,999", "$125k+")) %>%
      fct_relevel("< $25k"),
    EHG3_01B = factor(EHG3_01B, levels = 1:7,
                      labels = c("Less than HS", "HS diploma/equiv",
                                 "Trade cert/diploma", "College/CEGEP non-univ",
                                 "Univ < Bachelor", "Bachelor's", "Univ > Bachelor")) %>%
      fct_relevel("HS diploma/equiv"),
    REE_03   = factor(REE_03, levels = 1:6,
                      labels = c("At least once a day","At least once a week",
                                 "At least once a month","At least 3 times a year",
                                 "Once or twice a year","Not at all")) %>%
      fct_relevel("Not at all"),
    SEX      = factor(SEX, levels = c(1, 2), labels = c("Male", "Female"))
  ) %>%
  filter(!is.na(SLM_01), !is.na(FAMINCG2),
         !is.na(EHG3_01B), !is.na(REE_03), !is.na(SEX))

saveRDS(dat_clean, "2017_GSS_recode.Rds")

# 5. ---- Peek at cleaned data ----
count(dat_clean, FAMINCG2)
count(dat_clean, EHG3_01B)
count(dat_clean, REE_03)
count(dat_clean, SEX)

# 6. ---- Add packages to add replicate weights ----
library(survey)


# 7. ---- Define survey design with bootstrap replicate weights ----
des <- svrepdesign(
  weights     = ~WGHT_PER,
  repweights  = "WTBS_[0-9]+",   # matches WTBS_001 ... WTBS_500
  type        = "bootstrap",
  data        = dat_clean,
  combined.weights = TRUE
)



# 8. ---- Descriptives ----

n_unweighted <- nrow(dat_clean)
n_unweighted


# 9. ---- Weighted mean and variance of Life satisfaction (SLM_01) ----
slm_mean <- svymean(~SLM_01, des, na.rm = TRUE)
slm_var  <- svyvar(~SLM_01, des, na.rm = TRUE)

slm_row <- tibble(
  Variable = "Life satisfaction (0–10)",
  Level    = "Mean (SD)",
  Estimate = sprintf("%.2f (%.2f)", 
                     as.numeric(coef(slm_mean)),
                     sqrt(as.numeric(slm_var))),
  CI       = sprintf("%.2f–%.2f", 
                     confint(slm_mean)[1], 
                     confint(slm_mean)[2])
)

# 10. ---- Define Categorical variables
cat_vars <- c("FAMINCG2", "EHG3_01B", "REE_03", "SEX")

cat_rows <- lapply(cat_vars, function(v) {
  # weighted proportions
  means <- svymean(as.formula(paste0("~", v)), des, na.rm = TRUE)
  cis   <- confint(means)
  tibble(
    Variable = v,
    Level    = names(coef(means)),
    Estimate = sprintf("%.1f%%", 100 * coef(means)),
    CI       = sprintf("%.1f–%.1f%%", 100 * cis[, 1], 100 * cis[, 2])
  )
}) %>% bind_rows()

# 11. ---- Combine
descriptives_tbl <- bind_rows(slm_row, cat_rows)

# 12. ---- View the table ----
print(descriptives_tbl, n=Inf)

# 13. ---- Bivariate analysis ----

# Bivariate regression: Life satisfaction ~ Income
m_income <- svyglm(SLM_01 ~ FAMINCG2, design = des)

# Regression summary
summary(m_income)

# Wald test for overall significance of income
regTermTest(m_income, ~FAMINCG2)


# ---- Run regression: Life satisfaction ~ income + education + religion ----
m_boot <- svyglm(
  SLM_01 ~ FAMINCG2 + EHG3_01B + REE_03 + SEX,
  design = des
)

# ---- Results ----
summary(m_boot)


# Wald score for model 

regTermTest(m_boot, ~FAMINCG2 + EHG3_01B + REE_03)






