# idaifieldR 0.2.2 _2022_
* config specific names now removed everywhere 
* more tests

# idaifieldR 0.2.1 _2022-10-23_
* Fixed `find_layer()` (internal), seems to work as intended now.
* With the editor for the project configuration in iDAI.field 3, new fields and objects started to be named according to their configurations, e.g. "milet:temperType" etc., if the fields have been newly created. From now on those config specific names are removed from all fields, so that only the part after the double dot remains (e.g. "milet:temperType" becomes "temperType").
* `check_if_uid()` now handles vectors
* Speed up `get_uid_list()`, `replace_uid()`, `convert_to_onehot()`, and `fix_relations()` (a lot)
* split up import with `get_idaifield_docs()` and processing to be more usable with `simplify_idaifield()`, with advice to use the latter only on subsets so the time is more manageable. 
* add `check_and_unnest()` to export


# idaifieldR 0.2.0 _2022-05-15_

* Version number changed to 0.2, to reflect the rather dramatic changes.
* Faster `get_uid_list()` using `lapply()`
* Added `idf_query()` to specifically query the db for groups without first downloading everything
* Added `idf_index_query()` to specifically query the db for things that are only available in the uidlist (needs a uidlist to do that)
* `simplified = TRUE` (`simplify_idaifield()`) will now convert checkbox field to multiple columns. I should probably make this an option in the future, but I need to clean up that function first (TODO).
* make it possible to import the configuration file (needed for some new functions; will only work with idaifield3 and up, hopefully); connection and projectname are now attributes of the "idaifield_docs" and "idaifield_resources" objects.
* `idaifield_as_matrix()` now returns a matrix with character values, not lists
* Dimension lists will be imported as a single value - this is still stupid, actually, but I can't currently think of a better way.
* Two Vignettes: Demo.Rmd with essential workflow, about.Rmd explaining a bit more. Demo.Rmd updated to begin working on that.


I stated that I don't intend any structural changes, but that - apparently - was impossible. Old scripts will not work without interference with the new version.

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
