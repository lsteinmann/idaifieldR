% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_configuration.R
\name{get_configuration}
\alias{get_configuration}
\title{get_configuration: returns configuration list}
\usage{
get_configuration(connection, projectname = "rtest")
}
\arguments{
\item{connection}{A connection object as returned by `connect_idaifield()`}

\item{projectname}{The name of the project in the Field Client that one
wishes to load.}
}
\value{
a list containing the project configuration; NA if the configuration
could not be found
}
\description{
This function retrieves the project configuration (if existent) from an
iDAI.field project.
}
\examples{
\dontrun{
conn <- connect_idaifield(serverip = "127.0.0.1",
user = "R", pwd = "hallo")
config <- get_configuration(connection = conn,
projectname = "rtest")
}
}