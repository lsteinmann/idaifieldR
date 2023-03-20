
# idaifieldR

<!-- badges: start -->
[![R-CMD-check](https://github.com/lsteinmann/idaifieldR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lsteinmann/idaifieldR/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/lsteinmann/idaifieldR/branch/main/graph/badge.svg)](https://codecov.io/gh/lsteinmann/idaifieldR?branch=main)
<!-- badges: end -->

idaifieldR imports data from the [iDAI.field 2 / Field Desktop database](https://github.com/dainst/idai-field) into R. The core functions of this package use the [CouchDB-API](https://docs.couchdb.org/en/stable/api/database/index.html) to connect to a running iDAI.field 2 or 3 (Field Desktop) client and store the whole database or a subset in a list in R (in memory), avoiding the csv-export that would otherwise be needed and gathering all documents at once, which is not possible with said csv-export. Any R-Script using idaifieldR to import the database can be re-run and updated with new data flexibly without exporting from the Field client itself. 

The exports can be automatically formatted for easier processing in R (e.g. UIDs are replaced with the appropriate Identifiers, lists are somewhat unnested, and the geometry is reformatted to be usable with the [sp](https://cran.r-project.org/web/packages/sp/index.html)-package). See the Demo-Vignette for more info. However, processing all resources from the database is very slow for larger databases and uses up a lot of memory. 

## Dependencies

idaifieldR needs a syncing [iDAI.field/Field Desktop-Client](https://github.com/dainst/idai-field) on the same computer or in the same network to work. Other than that, the package depends on [crul](https://cran.r-project.org/web/packages/crul/index.html) and [jsonlite](https://cran.r-project.org/web/packages/jsonlite/index.html), both available on CRAN and automatically installed as dependencies. 

## Installation

You can install the current version of idaifieldR from github using `devtools` or `remotes`:

``` r
devtools::install_github("lsteinmann/idaifieldR", build_vignettes = TRUE)
```

## Example / Basic 

This is a basic example which shows you how to use idaifieldR. See the Demo.Rmd-vignette (`browseVignettes("idaifieldR")`), if it has been build) for a bit more explanation or the TLDR.Rmd-vignette for a very short example. 

In the example below, all the resources/documents from the project "rtest" are imported into a single list of lists. After building the UID-List (a sort of Index to the database) and only "Pottery"-resources are selected: `select_by_type()` narrows down the initial list to one type -- Pottery in the example -- but still returns a list of lists. (Internal names have to be used here, translations for the GUI will not work.) In the next step, the UUIDs are replaced with identifiers and the amount of unnecessary nesting is reduced with `simplify_idaifield()`. If a configuration is available, variables from checkbox-fields are also converted to multiple columns with boolean values. The same can be achieved when querying the database with `idf_query()`. `idaifield_as_matrix()` will produce a (depending on your data) large matrix, where every row is a database entry (a resource) and every column a field, or a value from a checkbox field. The matrix can easily be coerced to a data.frame, but it will still be necessary to adjust column types. 

``` r
library(idaifieldR)
idaifield_docs <- get_idaifield_docs(projectname = "rtest",
  connection = connect_idaifield(serverip = "127.0.0.1",
                                 user = "R", 
                                 pwd = "password"))
uidlist <- get_uid_list(idaifield_docs)
pottery <- select_by(idaifield_docs, by = "type", value = "Pottery")
pottery <- simplify_idaifield(pottery, uidlist = uidlist)

pottery_mat <- idaifield_as_matrix(pottery)

View(pottery_mat)
```

