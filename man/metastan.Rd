\name{metastan}
\alias{metastan}
\title{Compile metastan code into JAGS code}
\description{
Compiles metastan code (specified as an R expression) into JAGS code. 
}
\usage{
metastan(...)
}
\arguments{
  \item{...}{
Metastan code for named Stan blocks, specified as bare R expressions. The
name of the argument to this function is used as the name of the Stan block
in the compiled code, with underscores replaced with spaces (e.g. 
\code{transformed_parameters} becomes the block \code{transformed parameters}).
}
}
\details{
\code{metastan} integrates Stan model specification more easily into R by
allowing Stan models to be specified as bare R code rather than as character
strings. Because R and Stan are syntactically similar, with only a few 
exceptions, metastan models look very similar to Stan models. The primary
exception is variable declaration, where the Stan syntax is C-like (\code{type variable}), and
looks like this:

\code{
int a;
real<lower=0> x;
vector<lower=-1,upper=1>[3,3] c[10];
}

By contrast, metastan reverses the declaration order (\code{variable : type}),
for example:
 
\code{
a : int
x : real(lower=0)
c[10] : vector(lower=-1,upper=1)[3,3]
}

This syntax has the advantage that the order you read subscripts in is the
same as the order they are declared in (e.g., in the above example, \code{c}
has subscripts \code{c[10,3,3]}, \emph{not} \code{c[3,3,10]}).

Compared to using strings to specify Stan code in R, this approach
approach has the advantage that syntax checking in R editors helps prevent
simple errors without having to attempt to compile the model with Stan, 
decreasing turnaround time when iterating on models.  
}
\value{
An object of class \code{c("metastan", "metamodel")}. Metastan models have 
the following functions:

\item{\link{code}}{ Returns the JAGS code for this model as a character string. }
}
\author{
Matthew Kay
}
\seealso{
See also \code{\link{code}} for extracting the resulting Stan model as a character
string, and \code{\link{metajags}} for the JAGS equivalent of this function.
}
\examples{\dontrun{
library(rstan)

# FIRST, using metastan:
model = metastan(
    data = {
        N : int(lower=0)
        x : vector[N]
        y : vector[N]
    },
    parameters = {
        alpha : real
        beta : real
        sigma : real(lower=0)
    },
    model = {
        y ~ normal(alpha + beta * x, sigma)
    }
)

#(some code setting up data_list, etc) 
#...

stan_fit = stan(code(model), data=data_list, ...)


#SECOND, the traditional way: The above metastan approach 
#is equivalent to the following more traditional approach:

model_string = "
    data {
        int<lower=0> N;
        vector[N] x;
        vector[N] y;
    }
    parameters {
        real alpha;
        real beta;
        real<lower=0> sigma;
    }
    model {
        y ~ normal(alpha + beta * x, sigma);
    }
"

stan_fit = stan(model_string, data=data_list, ...)
}}
\keyword{manip}
