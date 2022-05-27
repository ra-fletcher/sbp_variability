#*******************************************************************************
#
# Project: Canagliflozin, visit-to-visit blood pressure variability, and risk of 
#          cardiovascular, kidney, and mortality outcomes: pooled individual 
#          participant data from the CANVAS and CREDENCE trials
# Date:    26-May-2022
# Author:  Robert A Fletcher
# Purpose: Reproducible example (reprex) with methods to calculate systolic 
#          blood pressure (SBP) variability
#
#*******************************************************************************


# Notes -------------------------------------------------------------------

# The only package requirements for the calculations as written below are 
# `dplyr`, `magrittr`, and `tidyselect`. At the time of analysis, the following 
# package versions were used:

# `dplyr` : v1.0.7
# `magrittr` : v2.0.1
# `tidyselect` : v1.1.1


# Load libraries ----------------------------------------------------------

library(tidyverse)


# Set seed ----------------------------------------------------------------

set.seed(69)


# Define reprex data ------------------------------------------------------

sbp_rpt <- 
  tibble::tibble( 
    id = paste0("100", seq(1, 1000, 1)),
    sbp_03_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_06_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_12_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_18_month = sample(90:180, size = 1000, replace = TRUE)
  )


# Calculate systolic blood pressure variability (SBP) parameters ----------

# Mean, standard deviation (SD), and coefficient of variation (CV)
sbp_var <- sbp_rpt %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    # Mean
    sbp_mean = mean(dplyr::c_across(tidyselect::starts_with("sbp"))),
    # SD
    sbp_sd = sd(dplyr::c_across(tidyselect::starts_with("sbp")))
  ) %>%
  dplyr::ungroup() %>%
  # CV
  dplyr::mutate(sbp_cv = (sbp_sd / sbp_mean) * 100)

# Variability independent of the mean (VIM)

# According to the literature, VIM is computed by dividing an individual’s SD to 
# the mean^x and multiplying it by the population’s mean^x, where `x` is derived 
# by fitting a non-linear regression curve of SD against the mean

# Non-linear least squares regression of SD against the mean (note that `k` is 
# a scaling factor which allows the function more flexibility when fitting the
# power [`x`])
nls_vim <- nls(sbp_sd ~ k * sbp_mean^x, data = sbp_var, start = c(k = 1, x = 1))

# Extract `x`
x <- coef(nls_vim)[2]

# VIM
sbp_var2 <- sbp_var %>%
  dplyr::mutate(sbp_vim = sbp_sd / sbp_mean^x * mean(sbp_mean)^x)
