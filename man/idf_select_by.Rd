% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/select_idaifield.R
\name{idf_select_by}
\alias{idf_select_by}
\title{Select/Filter an \code{idaifield_resources}- or \code{idaifield_docs}-list}
\usage{
idf_select_by(idaifield_docs, by = NULL, value = NULL)
}
\arguments{
\item{idaifield_docs}{An \code{idaifield_resources}- or \code{idaifield_docs}-list
as returned by \code{\link[=get_idaifield_docs]{get_idaifield_docs()}}  or \code{\link[=idf_query]{idf_query()}}, \code{\link[=idf_index_query]{idf_index_query()}},
and \code{\link[=idf_json_query]{idf_json_query()}}.}

\item{by}{Any name of a field that might by present in the resource lists,
e.g. category, identifier, processor etc.}

\item{value}{character. Should be the internal name of the value
that will be selected for (e.g. "Layer", "Pottery"), can also be vector of
multiple values.}
}
\value{
A list of class \code{idaifield_resources} containing the resources
which contain the specified values.
}
\description{
Subset or filter the list of the \emph{docs} or \emph{resources} by the
given parameters. You may want to consider querying the database
directly using \code{\link[=idf_query]{idf_query()}}, \code{\link[=idf_index_query]{idf_index_query()}}, or \code{\link[=idf_json_query]{idf_json_query()}}.
}
\examples{
\dontrun{
connection <- connect_idaifield(serverip = "127.0.0.1",
user = "R", pwd = "hallo", project = "rtest")
idaifield_docs <- get_idaifield_docs(connection = connection)

idaifield_layers <- idf_select_by(idaifield_docs,
by = "category",
value = "Layer")

idaifield_anna <- idf_select_by(idaifield_docs,
by = "processor",
value = "Anna Allgemeinperson")
}
}
\seealso{
\code{\link[=get_idaifield_docs]{get_idaifield_docs()}}, \code{\link[=idf_show_categories]{idf_show_categories()}}
\code{\link[=idf_query]{idf_query()}}, \code{\link[=idf_index_query]{idf_index_query()}}, \code{\link[=idf_json_query]{idf_json_query()}}
}
