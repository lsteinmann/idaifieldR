% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_layer.R
\name{find_parent_layer}
\alias{find_parent_layer}
\title{takes and returns a parent list recursively
until as much as possible is solved}
\usage{
find_parent_layer(
  parent_list,
  uidlist,
  id_type,
  layer_categories,
  max_depth = 20
)
}
\arguments{
\item{parent_list}{a list with solved and unsolved resources}

\item{uidlist}{A data.frame as returned by \code{\link[=get_field_index]{get_field_index()}} or
\code{\link[=get_uid_list]{get_uid_list()}}.}

\item{id_type}{One of "identifier" or "UID" - Should the function use
\emph{identifier}s or \emph{UUID}s to find the layer?}

\item{layer_categories}{A vector of \emph{categories} that are classified as
\emph{Layer}s. (Encompasses \emph{SurveyUnit}.) See or change the default:
\code{getOption("idaifield_categories")$layers}}

\item{max_depth}{numeric. Maximum number of recursive
iterations / maximum depth a resource may be nested below its layer.}
}
\value{
a list with solved and unsolved resources
}
\description{
takes and returns a parent list recursively
until as much as possible is solved
}
\seealso{
\itemize{
\item \code{\link[=find_layer]{find_layer()}}.
}
}
\keyword{internal}
