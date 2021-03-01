#' Returns NA if an objects is empty
#'
#' (defense against empty list items from idaifield)
#' does basically nothing, just checking if input is of length 0 and if so
#' returning NA, if not returning the input untouched.
#'
#' @param item can be anything.
#'
#' @return
#' @export
#'
#' @examples
ifnotempty <- function(item) {
  if (length(item) == 0) {
    return(NA)
  } else {
    return(item)
  }
}
