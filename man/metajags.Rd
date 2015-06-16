\name{metajags}
\alias{metajags}
\title{Compile metajags code into JAGS code}
\description{
Compiles metajags code (specified as an R expression) into JAGS code. 
}
\usage{
metajags(model, data=NULL, ...)
}
\arguments{
  \item{model}{
Metajags code for the JAGS model block, specified as a bare R expression. 
}
  \item{data}{
Metajags code for the JAGS data block, specified as a bare R expression.
}
  \item{...}{
Metajags code for other JAGS blocks, specified as bare R expressions. The
name of the argument to this function is used as the name of the JAGS block
in the compiled code.
}
}
\details{
\code{metabayes} integrates JAGS model specification more easily into R by
allowing JAGS models to be specified as bare R code rather than as character
strings. Because R and JAGS are syntactically similar, with only a few 
exceptions, metajags models look exactly like JAGS models. This
approach has the advantage that syntax checking in R editors helps prevent
simple errors without having to attempt to compile the model with JAGS, 
decreasing turnaround time when iterating on models.  

To specify a model in metajags, simply write the code for each named JAGS 
block as an R expression and pass that code into this function.
}
\value{
An object of class \code{c("metajags", "metamodel")}. Metajags models have 
the following functions:

\item{\link{code}}{ Returns the JAGS code for this model as a character string. }
}
\author{
Matthew Kay
}
\seealso{
See also \code{\link{code}} for extracting the resulting JAGS model as a character
string, and \code{\link{metastan}} for the Stan equivalent of this function.
}
\examples{\dontrun{
library(runjags)

# FIRST, using metajags:
model = metajags(
    model = {
        #core model
        for (i in 1:n) {
            # latent variable log-linear model
            mu[i] <- b[1] + b[2]*x[i]
            y[i] ~ dnorm(mu[i], tau)
        }
        
        #priors
        b[1] ~ dnorm(0, 10)
        b[2] ~ dnorm(0, 10)
        tau ~ dgamma(0.01, 0.01)
    }
)

#(some code setting up data_list, etc) 
#...

jags_fit = run.jags(code(model), data=data_list, ...)


#SECOND, the traditional way: The above metajags approach 
#is equivalent to the following more traditional approach:

model_string = "
    model {
        #core model
        for (i in 1:n) {
            # latent variable log-linear model
            mu[i] <- b[1] + b[2]*x[i]
            y[i] ~ dnorm(mu[i], tau)
        }
        
        #priors
        b[1] ~ dnorm(0, 10)
        b[2] ~ dnorm(0, 10)
        tau ~ dgamma(0.01, 0.01)
    }
"

jags_fit = run.jags(model_string, data=data_list, ...)
}}
\keyword{manip}
