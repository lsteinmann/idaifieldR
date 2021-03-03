
# idaifieldR

<!-- badges: start -->
[![R-CMD-check](https://github.com/lsteinmann/idaifieldR/workflows/R-CMD-check/badge.svg)](https://github.com/lsteinmann/idaifieldR/actions)
[![Codecov test coverage](https://codecov.io/gh/lsteinmann/idaifieldR/branch/main/graph/badge.svg)](https://codecov.io/gh/lsteinmann/idaifieldR?branch=main)
[![Travis build status](https://travis-ci.com/lsteinmann/idaifieldR.svg?branch=main)](https://travis-ci.com/lsteinmann/idaifieldR)
<!-- badges: end -->

The goal of `idaifieldR` is to flexibly get data from the [`idaifield` database](https://github.com/dainst/idai-field) into R. The core functions of this package use [`sofa`](https://github.com/ropensci/sofa) (available on CRAN) to connect to a synching instance of `idaifield` and store the database in a list in R (in memory), avoiding the csv-export that would otherwise be needed. Any R-Script using `idaifieldR` to import the database can be re-run and updated with new data flexibly without exporting and saving from the `idaifield`-Client itself. 

This is currently usable, but in the state of a raw draft that has not seen much testing. I would be very happy if anyone interested clones/forks and pull-requests any improvements! 

While the basic import to R (in Form of List and data.frame) is already possible with this package, what I still want to do and would find very useful for others is: 
* improve on the documentation, so that the functions and workflow are more understandable
* test a lot with actual data (will be happy about anyone submitting issues!)
* make it easier to understand and use this package
* I would also very much like to make it somewhat accessible to people not very (but somewhat) familiar with R, as the current output still requires some reformatting that might not be very easy for new users.


And a bit further: 
* can this be made into a shiny app?

## Dependencies

`idaifieldR` depends on the r-package [`sofa`](https://github.com/ropensci/sofa) (available on CRAN) and obviously needs a synching [`idaifield`-Client](https://github.com/dainst/idai-field) in the network to work.

## Installation

You can install the current version of `idaifieldR` from github using devtools:

``` r
devtools::install_github("lsteinmann/idaifieldR", build_vignettes = TRUE)
```



## Example / Basic 

This is a basic example which shows you how to use `idaifieldR`. See the Demo.Rmd-vignette (browseVignettes("idaifieldR"), if it has been build) for a bit more explanation. The example below will produce a (depending on you database) large Matrix containing lists, where every row is a database entry and every column a field. It is basically the same output as the csv-Export from the client. The matrix can without further issues be coerced to a data.frame. (Relations are still references as UIDs. You can use `get_uid_list(idaifield_docs)` for a lookup table.

``` r
library(idaifieldR)
idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
                                     projectname = "testproj", 
                                     user = "R",
                                     pwd = "password")
                                     
pottery <- select_by_type(idaifield_docs, "Pottery")

pottery_mat <- idaifield_as_matrix(pottery)

View(pottery_mat)
```

