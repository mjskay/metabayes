\name{code}
\alias{code}
\alias{code.metamodel}
\alias{as.character.metamodel}
\title{Get the JAGS or Stan code from a metajags or metastan model.}
\description{
Returns a character containing the compiled JAGS or Stan code from a 
metajags or metastan model. 
}
\usage{
\method{code}{metamodel}(x, ...)
\method{as.character}{metamodel}(x, ...)
}
\arguments{
  \item{x}{
A metabayes model (e.g. an object with class \code{"metabayes"}) such
as returned by \code{\link{metajags}} or \code{\link{metastan}}. 
}
  \item{...}{
Additional arguments passed to or from other methods.
}
}
\details{
The \code{code} method returns a character string containing the compiled JAGS 
or Stan code from a metajags or metastan model.

For \code{"metabayes"} and derived object, \code{as.character(x)} returns the 
same value as \code{code(x)}.  
}
\value{
A character string. 
}
\author{
Matthew Kay
}
\seealso{
See also \code{\link{metajags}}, \code{\link{metastan}}.
}
\keyword{manip}
