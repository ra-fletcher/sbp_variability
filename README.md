# Calculation of systolic blood pressure variability <a href='https://www.georgeinstitute.org'><img src='figs/tgi.png' align="right" height="150" /></a>

<!-- badges: start -->
![Languages](https://img.shields.io/badge/Languages-R-6498d3)
![Conducted By](https://img.shields.io/badge/Conducted%20By-The%20George%20Institute%20for%20Global%20Health-72297c)
<!-- badges: end -->

This repository provides a how-to guide and accompanying R code with a reprex to calculate three metrics of systolic blood pressure (SBP) variability used in analyses in *Fletcher RA et al. (2022)*.


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

The reprex code starts by generating a tibble of 1000 rows (each which mimics the data used in our study.

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


## Repository Authors

**Rob Fletcher, MSc (Oxon)** - Biostatistician | The George Institute for Global Health, Sydney, Australia

**Patrick Rockenschaub, MSc PhD** - Research Fellow | Charité Lab for Artificial Intelligence in Medicine, Charité Universitätsmedizin Berlin, Berlin, Germany

**Brendon Neuen, MBBS (Hons) MSc (Oxon)** - Academic Nephrology Registrar | The George Institute for Global Health, Sydney, Australia


## Contact

Please feel free to contact me via my [email](mailto:rfletcher@georgeinstitute.org.au?subject=Inquiry) should you have any questions.
