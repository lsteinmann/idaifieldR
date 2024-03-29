% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_uid_list.R
\name{get_field_index}
\alias{get_field_index}
\title{Get the Index of an iDAI.field / Field Desktop Database}
\usage{
get_field_index(
  connection,
  verbose = FALSE,
  gather_trenches = FALSE,
  remove_config_names = TRUE,
  find_layers = FALSE,
  language = "all"
)
}
\arguments{
\item{connection}{An object as returned by \code{\link[=connect_idaifield]{connect_idaifield()}}}

\item{verbose}{TRUE or FALSE. Defaults to FALSE. TRUE returns a list
including identifier and shortDescription which is more convenient to read,
and FALSE returns only UUID, category (former: type) and basic relations,
which is sufficient for internal use.}

\item{gather_trenches}{defaults to FALSE. If TRUE, adds another column that
records the Place each corresponding Trench and its sub-resources lie within.
(Useful for grouping the finds of several trenches, but will only work if the
project database is organized accordingly.)}

\item{remove_config_names}{TRUE/FALSE: Should the name of the project be
removed from field names of the configuration? (Default is TRUE.)
(Should e.g.: \emph{test:amount} be renamed to \emph{amount},
see \code{\link[=remove_config_names]{remove_config_names()}}.)}

\item{find_layers}{TRUE/FALSE. Default is FALSE. If TRUE, adds another column
with the 'Layer' (see \code{getOption("idaifield_categories")$layers}, can be
modified) in which a resource is contained  recursively. That means that
even if it does not immediately lie within this layer, but is
contained by one or several other resources in said layer, a new column
("liesWithinLayer") will still show the layer.
Example: A sample "A" in Find "001" from layer "Layer1" will
usually have "001" as the value in "liesWithin". With find_layers, there will
be another column called "liesWithinLayer" which contains "Layer1" for both
sample "A" and Find "001".}

\item{language}{The short name (e.g. "en", "de", "fr") of the language
that is preferred for the fields. Special value "all" (the default) can be
used to return a concatenated string of all available languages.
\code{\link[=gather_languages]{gather_languages()}} will select other available languages
in alphabetical order if the selected language is not available.}
}
\value{
a data.frame with identifiers and corresponding UUIDs along with
the category (former: type), basic relations and depending on settings place
and shortDescription of each element
}
\description{
All resources in the project databases in iDAI.field /
Field Desktop are stored and referenced with their Universally Unique
Identifier (UUID) in the relations fields. Therefore, for many purposes a
lookup-table needs to be provided in order to get to the actual identifiers
of the resources referenced. Single UUIDs or vectors of UUIDs can be
replaced individually using \code{\link[=replace_uid]{replace_uid()}} from this package.

This function is also good for a quick overview / a list of all the
resources that exist along with their identifiers and short descriptions
and can be used to select the resources along their respective
Categories (e.g. Pottery, Layer etc., formerly names "types").
Please note that in any case the internal names of everything will be used.
If you relabeled \code{Trench} to \code{Schnitt} in your language-configuration,
the name will still be \code{Trench} here. None of these functions have any
respect for language settings of a project configuration, i.e. the
front end languages of valuelists and fields are not displayed, and
instead their background names are used. You can see these in the project
configuration settings.
}
\examples{
\dontrun{
connection <- connect_idaifield(pwd = "hallo", project = "rtest")

index <- get_field_index(connection, verbose = TRUE)
}
}
\seealso{
\itemize{
\item \code{\link[=get_uid_list]{get_uid_list()}} returns the same data.frame from an \code{idaifield_docs} or
\code{idaifield_resources}-list without querying the database.
\item \code{\link[=find_layer]{find_layer()}} is used when \code{find_layers = TRUE} to search for the
containing layer-resource recursively.
}
}
