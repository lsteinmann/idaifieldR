% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simplify_utilities.R
\name{convert_to_onehot}
\alias{convert_to_onehot}
\title{Break down a List from a Checkbox Field to Onehot-Coded Values}
\usage{
convert_to_onehot(resource, fieldtypes)
}
\arguments{
\item{resource}{The resource to process (from an \code{idaifield_resources}-list).}

\item{fieldtypes}{A matrix of fields with the given inputType as
returned by \code{\link[=get_field_inputtypes]{get_field_inputtypes()}}}
}
\value{
The resource object with the values of checkboxes
separated into one-hot-coded versions.
}
\description{
This function is a helper function to
\code{\link[=simplify_idaifield]{simplify_idaifield()}} that takes a list from one of the
fields marked in the config as containing checkboxes and converts
the list to onehot-coded values.
}
\examples{
\dontrun{
...
}
}
\seealso{
\itemize{
\item This function is used by: \code{\link[=simplify_idaifield]{simplify_idaifield()}}
\item Needs output of: \code{\link[=get_field_inputtypes]{get_field_inputtypes()}}
}
}
