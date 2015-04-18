# metajags: R Package for specifying JAGS models directly as R code rather than as embedded strings 

_Matthew Kay, University of Washington <mjskay@uw.edu>_

`metabayes`  aims to integrate JAGS model specification more easily into R by
allowing JAGS models to be specified as bare R code rather than as character
strings. Because R and JAGS are syntactically similar, with only a few 
exceptions (see below) metajags models look exactly like JAGS models. This
approach has the advantage that syntax checking in R editors helps prevent
simple errors without having to attempt to compile the model with JAGS, 
decreasing turnaround time when iterating on models.  

## Installation

You can install the latest development version from GitHub with these R
commands:

```r
install.packages("devtools")
devtools::install_github("mjskay/metabayes")
```

## Example

Consider the following typical approach (without metajags) for JAGS model specification for
a simple linear regression, which uses a character string to specify the model:

```r
library(runjags)

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
}"

#(some code setting up data_list, etc) 
#...

jags_fit = run.jags(model_string, data=data_list, ...)
```

With metajags, we can instead specify the model directly as R code:

```r
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
```

## Differences from JAGS
There are some situations in which JAGS code cannot be used exactly as-is
in metajags.

### Truncation 
Because R syntax does not allow function calls to be placed adjacent to each other
without an operator in between, it is not possible to specify truncation directly
using the JAGS syntax:

```r
X ~ dnorm(0, 1) T(L,U)      #will not work in metajags
```

Metajags includes the `%c%` operator (not in normal JAGS), which simply concatenates 
two JAGS expressions in the output. For example:

```r
X ~ dnorm(0, 1) %c% T(L,U)  #works in metajags
```

Compiles to the JAGS code specified above.


## Extensions to JAGS

Metajags includes a few simple metaprogramming statements not found in base JAGS. These
are evaluated once, when the metajags model is compiled.

### `if` statement

If statements may be used for conditional compilation in metajags:

```r
if (R_expression) {
    #metajags code
} else {
    #metajags code
}
```

The else clause is optional.

`R_expression` is an R expression that is evaluated _immediately
when the metajags specification is compiled_; if it is `TRUE`, the first 
block of metajags code is included in the specification, if it is `FALSE`, the
second block is included (or nothing, if the `else` clause is omitted). 

In other words, the `R_expression` is evaluated only once (when the model is compiled). 
This statement is useful for conditionally including/excluding parts of the model specification.

### `R` statement
`R(R_expression)` allows arbitrary R code to be executed when the metajags code is compiled.
This expression should return a quoted R expression (e.g. as returned by `quote()`), which
will be treated as metajags code and compiled.


## Problems

Should you encounter any issues with this package, contact Matthew Kay
(<mjskay@uw.edu>). If you have found a bug, please file it [here]
(https://github.com/mjskay/metajags/issues/new) with minimal code to reproduce
the issue.

