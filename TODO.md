# TODO

## In general
* Better structure of tests with less specialized cases?
* Update the couch-db action a bit? See problems with _changes etc., and different configurations and contents.
* Remove the project(name) argument/option everywhere except in `connect_idaifield()` (because it doesn't really make that much sense.)
* Fix everything about `find_layer()`

## for v0.3.4 ?
* Handling geometry does not work very well and should be reconsidered. Maybe 
by importing some package like sf and storing the geometry as sf-objects, 
though this seems overkill. Or keep original JSON-string somehow to be useable
GeoJSON...?
* `remove_config_names()` may or may not overwrite data with the information
from unused fields, and I have to check that, though I have not yet noticed 
any problem.

## for 1.0.0
* Getting CRAN-ready: Better structured tests that do not depend on DB-connections.
* Reduced messaging behaviour. 
* Reduced functions, make it easier to maintain somehow. 
* Clean up old code.
