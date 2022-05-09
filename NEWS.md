# idaifieldR 0.2.0 _2022-02-10_

* Version number changed to 0.2, to reflect the dramatic changes (that have not yet taken place).
* Faster `get_uid_list()` using `lapply()`
* Added `idf_query()`, todo: will rely more on couchDB-queries in the future and therefore need to redo a lot of the package
* Demo.Rmd updated to begin working on that.

I stated that I don't intend any structural changes, but that - apparently - was a stupid idea. However, the old functions remain as they were.

# idaifieldR 0.1.4 _2021-05-09_

* add version to connect_idaifield()-function since options have changed with the switch to Field Desktop (iDAI.field 3)
* update documentation accordingly

# idaifieldR 0.1.3 _2021-12-07_

* Updated docs
* Changes geometry reformatting to accommodate 3D-data (if not available, set to 0)

# idaifieldR 0.1.1 _2021-04-13_

First release. 

I will try to limit future changes so that they will not affect the structural outcome of the core functions as they are now. 

TODOs:
* Find a way to handle the remaining lists better, esp in combination with the non-list columns.
* Try to assign column type automatically (numeric for numbers etc.)
* How to deal with the dimension...-fields (measurements)? Currently ignored, can be flattened with dplyr and friends.


# idaifieldR 0.1.0 _2021-03-03_

* Added a `NEWS.md` file to track changes to the package.
* Basic functions work but are not thoroughly tested
