check_if_idaifield <- function(...) {
  stop("`check_if_idaifield()` has been removed.")
}

reformat_geometry <- function(...) {
  stop("`reformat_geometry()` has been removed.")
}

download_language_list <- function(...) {
  stop("`download_language_list()` has been removed.")
}

extract_field_names <- function(...) {
  stop("`extract_field_names()` has been removed.")
}

get_language_lookup <- function(...) {
  stop("`get_language_lookup()` has been removed.")
}

get_field_inputtypes <- function(...) {
  stop("`get_field_inputtypes()` has been removed. Use `parse_field_inputtypes()`.")
}

get_uid_list <- function(...) {
  .Deprecated("make_index()", package = "idaifieldR", old = "get_uid_list()")
  make_index(...)
}
