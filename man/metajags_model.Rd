\name{metajags_model}
\alias{metajags_model}
\title{Compile metajags code into JAGS code}
\description{
Compiles metajags code (specified as an R expression) into JAGS code. 
}
\usage{
metajags_model(model)
}
\arguments{
  \item{model}{
A metajags model specified as an R expression. 
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

To specify a model in metajags, simply write the model code as an R expression
(without the containing \code{model { ... }} block) and pass it to 
\code{metajags_model()}.
}
\value{
An object of class \code{"jags_code"}: 

\item{code}{ The JAGS model specification as a character string. }
}
\author{
Matthew Kay
}
\examples{\dontrun{
library(runjags)

model = metajags_model({
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
})

#(some code setting up data_list, etc) 
#...

jags_fit = run.jags(model$code, data=data_list, ...)
}}
\keyword{manip}
