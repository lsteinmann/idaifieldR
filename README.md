
# idaifieldR

<!-- badges: start -->
[![R-CMD-check](https://github.com/lsteinmann/idaifieldR/workflows/R-CMD-check/badge.svg)](https://github.com/lsteinmann/idaifieldR/actions)
[![Codecov test coverage](https://codecov.io/gh/lsteinmann/idaifieldR/branch/main/graph/badge.svg)](https://codecov.io/gh/lsteinmann/idaifieldR?branch=main)
<!-- badges: end -->

idaifieldR imports data from the [iDAI.field 2 database](https://github.com/dainst/idai-field) into R. The core functions of this package use [sofa](https://github.com/ropensci/sofa) (available on CRAN) to connect to a running iDAI.field 2-client and store the whole database in a list in R (in memory), avoiding the csv-export that would otherwise be needed and gathering all documents at once, which is not possible with said csv-export. Any R-Script using idaifieldR to import the database can be re-run and updated with new data flexibly without exporting from the iDAI.field 2-client itself. 

When using the defaults, the entries are automatically formatted for easier processing in R (e.g. UIDs are replaced with the appropriate Identifiers, lists are somewhat unnested, and the geometry is reformatted to be usable with the [sp](https://cran.r-project.org/web/packages/sp/index.html)-package). See the Demo-Vignette for more info. 

## Dependencies

idaifieldR depends on the R-package [sofa](https://github.com/ropensci/sofa) (available on CRAN) and needs a syncing [iDAI.field 2-Client](https://github.com/dainst/idai-field) to work.

## Installation

You can install the current version of idaifieldR from github using devtools:

``` r
devtools::install_github("lsteinmann/idaifieldR", build_vignettes = TRUE)
```



## Example / Basic 

This is a basic example which shows you how to use idaifieldR. See the Demo.Rmd-vignette (`browseVignettes("idaifieldR")`), if it has been build) for a bit more explanation. In the example below, all the resources/documents from the project "rtest" are imported into a single list of lists. `simplify_idaifield()` replaces the UIDs with identifiers and reduces the amount of unnecessary nesting.  `select_by_type()` narrows down the initial list to one type -- Pottery in the example -- but still returns a list of lists. (Internal names have to be used here, translations for the GUI will not work.) `idaifield_as_matrix()` will produce a (depending on your data) large matrix containing lists, where every row is a database entry (a resource) and every column a field. The matrix can be coerced to a data.frame, but depending on what you are doing it will be necessary do reduce the columns from lists to anything else, and to adjust column types accordingly.

``` r
library(idaifieldR)
idaifield_docs <- get_idaifield_docs(projectname = "rtest",
  connection = connect_idaifield(serverip = "127.0.0.1",
                                 user = "R", 
                                 pwd = "password"))

pottery <- select_by(idaifield_docs, by = "type", value = "Pottery")

pottery_mat <- idaifield_as_matrix(pottery)

View(pottery_mat)
```

