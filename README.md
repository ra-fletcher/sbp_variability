# Calculation of systolic blood pressure variability <a href='https://www.georgeinstitute.org'><img src='figs/tgi.png' align="right" height="150" /></a>

<!-- badges: start -->
![Languages](https://img.shields.io/badge/Languages-R-6498d3)
![Conducted By](https://img.shields.io/badge/Conducted%20By-The%20George%20Institute%20for%20Global%20Health-72297c)
<!-- badges: end -->

## Overview

This repository provides a how-to guide and accompanying R reprex to calculate three metrics of systolic blood pressure (SBP) variability used in analyses in *Fletcher RA et al. (2022)*. These metrics are standard deviation (SD), coefficient of variation (CV), and variability independent of the mean (VIM).

## Dependencies

To get this code to work, please install all dependencies. Only three packages are required, all of which are included in the Tidyverse. These packages are: `dplyr`, `magrittr`, and `tidyselect`. To install the Tidyverse (if you haven't already), run the following script:

``` r
install.packages(setdiff("tidyverse", rownames(installed.packages())))
```

## Folder structure

Below is an overview of the folders in this repository that are actively synchronised with GitHub.

### code

`code` contains the reprex code: `sbp_variability_reprex.R`

### figs

`figs` contains the logo for The George Institute for Global Health used for the README

## Guide

The reprex code, `code/sbp_variability_reprex.R` starts by generating a tibble of 1000 rows (one row per one individual) which mimics the data used in our study. We have included four columns for four hypothetical repeat SBP measures at 3-months, 6-months, 12-months, and 18-months. You can easily extend our code to any number of repeat measures. The range of SBP values in this reprex has been (arbitrarily) specified as 90 to 180 mm Hg. 

``` r
set.seed(69)

sbp_rpt <- 
  tibble::tibble( 
    id = paste0("100", seq(1, 1000, 1)),
    sbp_03_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_06_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_12_month = sample(90:180, size = 1000, replace = TRUE),
    sbp_18_month = sample(90:180, size = 1000, replace = TRUE)
  )

sbp_rpt
#> # A tibble: 1,000 × 5
#>    id    sbp_03_month sbp_06_month sbp_12_month sbp_18_month
#>    <chr>        <int>        <int>        <int>        <int>
#>  1 1001           170          115          102          133
#>  2 1002           180          105          168           99
#>  3 1003            91          132          110          132
#>  4 1004           166          137          163          104
#>  5 1005           128          119           97          167
#>  6 1006           128          131           92          177
#>  7 1007            95          169          116          105
#>  8 1008            91          152          165          144
#>  9 1009           179          142          170          130
#> 10 10010          116          146          145          108
#> # … with 990 more rows
```

Calculation of mean, SD, and CV is pretty straightforward, as illustrated by the following code:

``` r
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
  
sbp_var
#> # A tibble: 1,000 × 8
#>    id    sbp_03_month sbp_06_month sbp_12_month sbp_18_month sbp_mean sbp_sd sbp_cv
#>    <chr>        <int>        <int>        <int>        <int>    <dbl>  <dbl>  <dbl>
#>  1 1001           170          115          102          133     130    25.6   19.7
#>  2 1002           180          105          168           99     138    36.3   26.3
#>  3 1003            91          132          110          132     116.   17.1   14.7
#>  4 1004           166          137          163          104     142.   24.9   17.5
#>  5 1005           128          119           97          167     128.   25.3   19.8
#>  6 1006           128          131           92          177     132    30.2   22.9
#>  7 1007            95          169          116          105     121.   28.6   23.5
#>  8 1008            91          152          165          144     138    28.2   20.4
#>  9 1009           179          142          170          130     155.   20.0   12.9
#> 10 10010          116          146          145          108     129.   17.0   13.2
#> # … with 990 more rows
```

Calculation of VIM, a transformation of the SD which is uncorrelated with the mean (useful because higher SD of SBP variability is correlated with higher mean SBP) requires running a non-linear least squares regression of SD against the mean.

``` r 
nls_vim <- nls(sbp_sd ~ k * sbp_mean^x, data = sbp_var, start = c(k = 1, x = 1))

nls_vim
#> Nonlinear regression model
#>  model: sbp_sd ~ k * sbp_mean^x
#>   data: sbp_var
#>     k      x 
#> 5.2212 0.2884 
#>  residual sum-of-squares: 56180
#> 
#> Number of iterations to convergence: 15 
#> Achieved convergence tolerance: 3.01e-06
```

Note that `k` is a scaling factor, and `x` is the power that we're aiming to derive from the regression. 
The formula for calculation VIM is:

> VIM = (SD/BP^x) × BPpopn^x

Where:
- `SD` is the intra-individual SD of the four measures
- `BP` is the intra-individual mean of the four measures
- `x` is the power derived from the non-linear regression
- `BPpopn` is the population mean of the four measures

``` r
x <- coef(nls_vim)[2]

x
#>        x 
#> 0.288358 

sbp_var2 <- sbp_var %>%
  dplyr::mutate(sbp_vim = sbp_sd / sbp_mean^x * mean(sbp_mean)^x)

sbp_var2
#> # A tibble: 1,000 × 9
#>    id    sbp_03_month sbp_06_month sbp_12_month sbp_18_month sbp_mean sbp_sd sbp_cv sbp_vim
#>    <chr>        <int>        <int>        <int>        <int>    <dbl>  <dbl>  <dbl>   <dbl>
#>  1 1001           170          115          102          133     130    25.6   19.7    25.8
#>  2 1002           180          105          168           99     138    36.3   26.3    36.0
#>  3 1003            91          132          110          132     116.   17.1   14.7    17.9
#>  4 1004           166          137          163          104     142.   24.9   17.5    24.5
#>  5 1005           128          119           97          167     128.   25.3   19.8    25.7
#>  6 1006           128          131           92          177     132    30.2   22.9    30.3
#>  7 1007            95          169          116          105     121.   28.6   23.5    29.4
#>  8 1008            91          152          165          144     138    28.2   20.4    27.9
#>  9 1009           179          142          170          130     155.   20.0   12.9    19.2
#> 10 10010          116          146          145          108     129.   17.0   13.2    17.2
#> # … with 990 more rows

sbp_var2 %>% 
  select(sbp_mean, sbp_sd, sbp_cv, sbp_vim) %>% 
  cor(method = "pearson")
#>             sbp_mean     sbp_sd     sbp_cv    sbp_vim
#> sbp_mean  1.00000000 0.07064698 -0.1591217 0.00453244
#> sbp_sd    0.07064698 1.00000000  0.9686714 0.99740812
#> sbp_cv   -0.15912169 0.96867138  1.0000000 0.98401798
#> sbp_vim   0.00453244 0.99740812  0.9840180 1.00000000
```

Note that in this reprex VIM is the least correlated with the mean (however the correlation of SD with mean is still also low).

## Repository Authors

**Robert A Fletcher, MSc (Oxon)** - Biostatistician | The George Institute for Global Health, Sydney, Australia

**Patrick Rockenschaub, PhD** - Research Fellow | Charité Lab for Artificial Intelligence in Medicine, Charité Universitätsmedizin Berlin, Berlin, Germany

**Brendon Neuen, MBBS (Hons) MSc (Oxon)** - Academic Nephrology Registrar | The George Institute for Global Health, Sydney, Australia

## Contact

Please feel free to contact Robert Fletcher via [email](mailto:rfletcher@georgeinstitute.org.au?subject=Inquiry) should you have any questions!
