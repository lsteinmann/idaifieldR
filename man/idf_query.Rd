% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/idf_query.R
\name{idf_query}
\alias{idf_query}
\title{Query \emph{docs} from an iDAI.field Database Directly}
\usage{
idf_query(
  connection,
  field = "category",
  value = "Pottery",
  projectname = NULL
)
}
\arguments{
\item{connection}{A connection settings object as
returned by \code{\link[=connect_idaifield]{connect_idaifield()}}}

\item{field}{character. The resource field that should be selected for
(i.e. "category" for the category of resource (\emph{Pottery}, \emph{Brick}, \emph{Layer})).}

\item{value}{character. The value to be selected for in the specified
field (i.e. "\emph{Brick}" when looking for resources of category \emph{Brick}).}

\item{projectname}{(deprecated) The name of the project to be queried (overrides
the one listed in the connection-object).}
}
\value{
An \code{idaifield_docs} list containing all \emph{docs} that fit the query parameters.
}
\description{
This function can be used to gather \emph{docs} from an iDAI.field / Field
Desktop Database according to the values of specific fields.
}
\examples{
\dontrun{
conn <- connect_idaifield(pwd = "hallo", project = "rtest")
idf_query(conn, field = "category", value = "Brick")
}
}
\seealso{
\itemize{
\item Alternative functions: \code{\link[=idf_index_query]{idf_index_query()}}, \code{\link[=idf_json_query]{idf_json_query()}}
}
}
