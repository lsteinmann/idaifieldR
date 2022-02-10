#' idf_query
#'
#' Queries resources from an iDAI.field 2-database that is currently running
#'
#' @param connection A connection object as returned by `connect_idaifield()`
#' @param project The name of the project to be queried.
#' @param field The resource field that should be selected for (i.e. "type" for
#' the type of resource (Pottery, Brick, Layer)).
#' @param value The value to be selected for in the specified field (i.e.
#' "Brick" when looking for resourced of type "Brick").
#'
#' @return A nested list with all matching docs and their metadata.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' idf_query(connection, project = "milet", field = "type", value = "Brick")
#' }
#'
idf_query <- function(connection, project,
                      field = "type",
                      value = "Brick") {

  query <- paste('{ "selector": { "resource.',
                 field, '": "', value, '"}}', sep = "")

  result <- sofa::db_query(cushion = connection,
                           dbname = project,
                           query = query)

  return(result[[1]])
}
