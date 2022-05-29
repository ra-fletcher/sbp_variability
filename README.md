# Calculation of systolic blood pressure variability <a href='https://www.georgeinstitute.org'><img src='figs/tgi.png' align="right" height="150" /></a>

<!-- badges: start -->
![Languages](https://img.shields.io/badge/Languages-R-6498d3)
![Conducted By](https://img.shields.io/badge/Conducted%20By-The%20George%20Institute%20for%20Global%20Health-72297c)
<!-- badges: end -->

This repository provides a how-to guide and accompanying R code with a reprex to calculate three metrics of systolic blood pressure (SBP) variability used in analyses in *Fletcher RA et al. (2022)*. These metrics are standard deviation (SD), coefficient of variation (CV), and variability independent of the mean (VIM).


## Dependencies

To get this code to work, please install all dependencies. Only three packages are required, all of which are included in the Tidyverse. These are: `dplyr`, `magrittr`, and `tidyselect`. To install the Tidyverse (if you haven't already), run the following script:

``` r
install.packages(setdiff("tidyverse", rownames(installed.packages())))
```

## Folder structure

Below is an overview of the folders in this repository that are actively synchronised with GitHub.

### code

`code` contains the reprex code.

### figs

`figs` contains the logo used for the README.md.


## Guide

The reprex code starts by generating a tibble of 1000 rows (each row is one individual) which mimics the data used in our study. We have included four columns for four hypothetical repeat SBP measures at 3-months, 6-months, 12-months, and 18-months.

``` r
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

## Repository Authors

**Rob Fletcher, MSc (Oxon)** - Biostatistician | The George Institute for Global Health, Sydney, Australia

**Patrick Rockenschaub, MSc PhD** - Research Fellow | Charité Lab for Artificial Intelligence in Medicine, Charité Universitätsmedizin Berlin, Berlin, Germany

**Brendon Neuen, MBBS (Hons) MSc (Oxon)** - Academic Nephrology Registrar | The George Institute for Global Health, Sydney, Australia


## Contact

Please feel free to contact me via my [email](mailto:rfletcher@georgeinstitute.org.au?subject=Inquiry) should you have any questions.
