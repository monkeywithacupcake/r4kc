
# r4kc

<!-- badges: start -->
<!-- badges: end -->

The goal of r4kc is to simplify reading and using data posted by Kitsap County in R. 

## Installation

You can install the development version of r4kc like so:

``` r
install_github("r4kc")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(r4kc)
## basic example code
commiss <- get_kc_data(get_dataset_name("commission"))
```

