% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/unnest_resource.R
\name{unnest_resource}
\alias{unnest_resource}
\title{Unnesting a idaifield_docs-List down to resource level}
\usage{
unnest_resource(idaifield_docs)
}
\arguments{
\item{idaifield_docs}{A list as provided by `sofa::db_alldocs(...)` when
importing from an iDAI.field 2-database using `get_idaifield_docs()`.
`get_idaifield_docs()` employs this function already
when setting `simplified = TRUE`, which is the default.
Mostly there is no need to deal with `unnest_resource()`. If one chooses
`get_idaifield_docs(..., simplified  = FALSE)`, it is possible to use
`unnest_resource()` on the resulting list to simplify it.}
}
\value{
a list of class idaifield_resources (same as idaifield_docs,
but the top-level with meta-information has been removed to make the actual
resource data more accessible)
}
\description{
This function unnests the lists provided by iDAI.field 2.
The actual data of a resource is usually stored in a sub-list
behind $doc$resource, which contains the data one would mostly
want to work with in R. The top level data contains information
about who created and modified the resource at what time and
is irrelevant for any analysis of the database contents itself.
}
\examples{
\dontrun{
connection <- connect_idaifield(serverip = "192.168.2.21",
user = "R", pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = connection,
projectname = "rtest", simplified = FALSE)

idaifield_resources <- unnest_resource(idaifield_docs)
}
}
\keyword{internal}
