% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/idaifield_as_matrix.R
\name{idaifield_as_matrix}
\alias{idaifield_as_matrix}
\title{idaifield_as_matrix}
\usage{
idaifield_as_matrix(idaifield_docs)
}
\arguments{
\item{idaifield_docs}{An object as returned by get_idaifield_docs(...)}
}
\value{
a matrix (depending on selection and database it can be very large)
}
\description{
Converts an idaifield_docs/idaifield_resource-list into a Matrix that
contains lists where multiple selections have been made in i.DAIfield 2,
which can be more flexible than the dataframe-approach in idaifield_as_df.
}
\details{
If the list containing all meta-info (i.e. the docs-list)
is handed to the function it will automatically unnest to resource level).
}
\examples{
\dontrun{
connection <- connect_idaifield(serverip = "192.168.2.21",
user = "R", pwd = "hallo")
idaifield_docs <- get_idaifield_docs(connection = connection,
projectname = "rtest", simplified = TRUE)

idaifield_mat <- idaifield_as_matrix(idaifield_docs)
}
}
