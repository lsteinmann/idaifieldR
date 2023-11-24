# idaifieldR 0.3.4 _2023-11-24_
* Make `get_field_index()` more efficient by utilizing vectors instead of `lapply()`. 

# idaifieldR 0.3.3 _2023-11-23_
### New features
* Add `idf_last_changed(connection, n = n)`: Returns a vector with the last n changed resources in the database. 
* Add `idf_get_changes(connection, ids = c(...))`: Returns a data.frame in which each change to one of the resources listed in ids (can be either their 'identifier' or 'UUID') corresponds to one row separated by creation or modification.
* `remove_config_names()` issues a message about duplicate field or category names if it is appropriate. Functions may override data when multiple columns with the same name would otherwise exist, as e.g. 'diameter' and 'projectName:diameter'. Attaches an attribute that lists the duplicate field/category names.

### Minor changes
* Notify of new / different version on GitHub on attaching the package (`check_idaifieldr_version()`).

### Fixes
* Fix problem in `reformat_geometry()` (MultiPolygons have to be unnested before processing). (Imported Polygons may be formatted improperly, unnest if necessary (`reformat_geometry()`). Geometry is still a *work in progress*.)
* Fix a bug in `get_field_index()`, where it would return an empty data.frame if there was no configuration-resource.

# idaifieldR 0.3.2 _2023-04-15_
* add option to use or not use exact dates as min/max values for dating if present
* add `idf_json_query()` which lets users construct their own queries to the CouchDB-API 
* improve and export `find_layer()`
* fix error in `get_language_lookup()`
* fix bug in `idf_query()`-function where it would not get values from fields with possibility of multiple entries
* remove config as attribute to save space
* rename `select_by()` to `idf_select_by()`
* rename `show_categories()` to `idf_show_categories()`
* update `idf_select_by()` and `idf_show_categories()`
* update vignettes
* update/enhanced documentation 
* add a sticker


# idaifieldR 0.3.1 _2023-04-02_
* of course, I missed half of it.
* fix `idf_query()`/`idf_index_query()`: rename "type" to "category" in resource lists
* type column in `idaifield_as_matrix()`
* fix renaming of type/category in `simplify_idaifield()`
* fix missed type/category issue `convert_to_onehot()`
* "solve" minor problem with spreading checkbox fields (#TODO)


# idaifieldR 0.3.0 _2023-04-02_
* remove sofa as dependency and add custom interface with reduced functionality
* restructure unnesting (`unnest_docs()` & `find_resource()`)
* add `get_field_index()` - getting the uidlist/index directly from the database
* exchange type with category everywhere (**Attention**: This may very well break previous scripts)
* speed up `find_layer()` significantly
* check if project exists before attempting to query the database

## Breaking changes:
* "type" does not refer to the type of resource (Find, Layer, Place etc.) any more and is renamed to category, as this is the current structure of the database. The uidlist-column "type" is renamed to "category" along with any reference to this information anywhere else (I hope ;) ). 

# idaifieldR 0.2.4 _2023-03-31_
## new:  

* handle / reformat dating fields by getting min and max date

## fixes:

* get type OR *category* if *type* is empty in for `get_uid_list()`
* multiple queries for `idf_query()` with *type* & *category*
* in `simplify_idaifield()`, *category* is currently switched to *type*, 
  but **this will be changed later** -> #TODO: rename type everywhere to
  category to reflect actual db structure

# idaifieldR 0.2.3 _2023-03-16_
* add language management for multi-language input fields when project has more than one project language
* add language list lookup preparation (`get_language_lookup()`) for custom config fields
* add `download_language_list()` to get current translations from GitHub
* add ping-checks for all database-related functions to supply custom error messages
* `get_idaifield_docs()` will now remove the Configuration as a doc and attach it as attribute to all custom classes, thus `simplify_idaifield()` will use the config-attribute directly and works without a connection. 
* `simplify_idaifield()` now allows to keep checkbox-fields etc. as-is
* change `idf_query()` and `idf_index_query()` to return docs instead of simplified list to allow choice
* all `idaifield_...`-lists are now named (with the identifier of each resource)
* new demodata for future use (`data("idaifieldr_demodata")`)
* rewritten vignettes and generally updated documentation
* **Notice**: The changes may have created problems for iDAI.field 2, and I did not test using the package with iDAI.field 2, as I assume it is not used anymore. `get_idaifield_docs()` should still work.

# idaifieldR 0.2.2 _2023-02-18_
* config specific names now removed everywhere
* fixed problem with if-condition when config exists
* fixed problem with the calculation of means for ranged measurements
* comments in the code in some places
* speed up `find_layer()`, `replace_uid()` and `check_if_uid()` 
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
