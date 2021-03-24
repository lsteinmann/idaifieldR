
# idaifieldR

<!-- badges: start -->
[![R-CMD-check](https://github.com/lsteinmann/idaifieldR/workflows/R-CMD-check/badge.svg)](https://github.com/lsteinmann/idaifieldR/actions)
[![Codecov test coverage](https://codecov.io/gh/lsteinmann/idaifieldR/branch/main/graph/badge.svg)](https://codecov.io/gh/lsteinmann/idaifieldR?branch=main)
<!-- badges: end -->

idaifieldR imports data from the [iDAI.field 2 database](https://github.com/dainst/idai-field) into R. The core functions of this package use [sofa](https://github.com/ropensci/sofa) (available on CRAN) to connect to a syncing iDAI.field 2-client and store the whole database in a list in R (in memory), avoiding the csv-export that would otherwise be needed and gathering all documents at once, which is not possible with said csv-export. Any R-Script using idaifieldR to import the database can be re-run and updated with new data flexibly without exporting from the iDAI.field 2-client itself.

This is currently usable, but in the state of a raw draft that has not seen much testing (and next to no testing on 'real' data). I would be very happy if anyone interested contributes! 

While the basic import to R (in form of list, matrix and data.frame) is already possible with this package, what I still want to do and would find very useful for others is: 
* improve on the documentation, so that the functions and workflow are more understandable
* test with actual data
* include some reformatting specific to the kind of data returned by the client
* I would also very much like to make it somewhat accessible to people not very (but somewhat) familiar with R, as the current output still requires some reformatting that might not be very easy for new users.

## Dependencies

idaifieldR depends on the R-package [sofa](https://github.com/ropensci/sofa) (available on CRAN) and needs a syncing [iDAI.field 2-Client](https://github.com/dainst/idai-field) to work.

## Installation

You can install the current version of idaifieldR from github using devtools:

``` r
devtools::install_github("lsteinmann/idaifieldR", build_vignettes = TRUE)
```



## Example / Basic 

This is a basic example which shows you how to use idaifieldR. See the Demo.Rmd-vignette (`browseVignettes("idaifieldR")`, if it has been build) for a bit more explanation. In the example below, all the resources/documents from the project "rtest" are imported into a single list of lists. `simplify_idaifield()` replaces the UIDs with identifiers and reduces the amount of unnecessary nesting.  `select_by_type()` narrows down the initial list to one type -- Pottery in the example -- but still returns a list of lists. (Internal names have to be used here, translations for the GUI will not work.) `idaifield_as_matrix()` will produce a (depending on your data) large matrix containing lists, where every row is a database entry (a resource) and every column a field. The matrix can without further issues be coerced to a data.frame, but depending on what you are doing it may be necessary do reduce the columns from lists to anything else.

``` r
library(idaifieldR)
idaifield_docs <- get_idaifield_docs(serverip = "192.168.1.21",
                                     projectname = "rtest", 
                                     user = "R",
                                     pwd = "password")
                                     
idaifield <- simplify_idaifield(idaifield_docs = idaifield_docs,
                                replace_uids = TRUE,
                                keep_geometry = FALSE)

pottery <- select_by_type(idaifield, "Pottery")

pottery_mat <- idaifield_as_matrix(pottery)

View(pottery_mat)
```

