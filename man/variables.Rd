\name{variables}
\alias{variables}
\title{Get the names of variables in a JAGS or Stan model.}
\description{
Returns a character vector containing the names of variables / symbols in a JAGS or Stan model. 
}
\usage{
variables(m)
}
\arguments{
  \item{m}{
A metabayes model (e.g. an object with class \code{"metabayes"}) such
as returned by \code{\link{metajags}} or \code{\link{metastan}}. 
}
}
\details{
The \code{variables} method returns a character vector containing the 
names of variables and symbols in the compiled JAGS or Stan code from a metajags or metastan model.
}
\value{
A character vector. 
}
\author{
Matthew Kay
}
\seealso{
See also \code{\link{metajags}}, \code{\link{metastan}}.
}
\keyword{manip}