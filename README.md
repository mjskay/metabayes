# metabayes: R Package for specifying Bayesian models (JAGS, Stan) directly as R code rather than as embedded strings 

_Matthew Kay, University of Washington <mjskay@uw.edu>_

`metabayes`  aims to integrate Bayesian model specification more easily into R by
allowing models for the JAGS and Stan languages to be specified as bare R code 
rather than as character strings. Metabayes models (dubbed _Metajags_ and _Metastan_) 
look very similar to the languages they compile to (JAGS and Stan respectively). 

This approach has the advantage that syntax checking in R editors helps prevent
simple errors without having to attempt to compile the model with JAGS, 
decreasing turnaround time when iterating on models.  

**Examples and documentation** for both [metajags](#metajags) and [metastan](#metastan) 
are below. 

## Installation

`metabayes` is still somewhat experimental and the API and specification is subject
to change at any time as I iterate on it, thus I have not submitted it to CRAN yet. 
You can install the latest development version from GitHub with these R commands:

```r
install.packages("devtools")
devtools::install_github("mjskay/metabayes")
```

# <a name="metajags"></a> Metajags: JAGS models specified as R code.

Due to the similarity in syntax between JAGS and R, most JAGS models
can be specified in Metajags with no changes, with the exception of
truncation (see [differences](#metajags-differences), below).

## Example

Consider the following typical approach (without Metajags) for JAGS model specification for
a simple linear regression, which uses a character string to specify the model:

```r
library(runjags)

model_string = "
    model {
        #core model
        for (i in 1:n) {
            mu[i] <- b[1] + b[2]*x[i]
            y[i] ~ dnorm(mu[i], tau)
        }
        
        #priors
        b[1] ~ dnorm(0, 10)
        b[2] ~ dnorm(0, 10)
        tau ~ dgamma(0.01, 0.01)
    }
"

#(some code setting up data_list, etc) 
#...

jags_fit = run.jags(model_string, data=data_list, ...)
```

With Metajags, we can instead specify the model directly as R code:

```r
library(metabayes)
library(runjags)

model = metajags(
    model = {
        #core model
        for (i in 1:n) {
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
```

## <a id="metajags-differences"></a> Differences from JAGS
There are some situations in which JAGS code cannot be used exactly as-is
in Metajags.

### Truncation 
Because R syntax does not allow function calls to be placed adjacent to each other
without an operator in between, it is not possible to specify truncation directly
using the JAGS syntax:

```r
x ~ dnorm(0, 1) T(L,U)      #will not work in Metajags
```

Metajags includes the `%c%` operator (not in normal JAGS), which simply concatenates 
two JAGS expressions in the output. For example:

```r
x ~ dnorm(0, 1) %c% T(L,U)  #works in Metajags
```

Compiles to the JAGS code specified above.

### Quoted JAGS code: a last resort
While Metajags has syntax to support all current base JAGS functionality, future
versions (or some modules) may introduce syntax that is not currently supported. In
that case, you can always include raw JAGS code directly by quoting it as a string.
For example:

```r
model = metajags(
    model = {
        #core model
        for (i in 1:n) {
            mu[i] <- b[1] + b[2]*x[i]
            y[i] ~ dnorm(mu[i], tau)
        }
    
        #priors
        "b[1] ~ dnorm(0, 10)"
        b[2] ~ dnorm(0, 10)
        tau ~ dgamma(0.01, 0.01)
    }
)
```

This results in the same model from above: in this case, `"b[1] ~ dnorm(0, 10)"` is
included directly as raw JAGS code. This is recommended **only as a last resort**, as
this code is not parsed by Metajags. That means, for example, that any variable names
included only in string expressions will not be identified by Metajags (functionality
that may be used in the future to automatically pull data from the R environment).

## Metaprogramming extensions to JAGS

Metajags includes a few simple metaprogramming statements not found in base JAGS. These
are evaluated once, when the Metajags model is compiled.

### `if` statement

If statements may be used for conditional compilation in Metajags:

```r
if (R_expression) {
    #metajags code
} else {
    #metajags code
}
```

The else clause is optional.

`R_expression` is an R expression that is evaluated _immediately
when the Metajags specification is compiled_; if it is `TRUE`, the first 
block of Metajags code is included in the specification, if it is `FALSE`, the
second block is included (or nothing, if the `else` clause is omitted). 

In other words, the `R_expression` is evaluated only once (when the model is compiled). 
This statement is useful for conditionally including/excluding parts of the model specification.

### `R` statement
`R(R_expression)` allows arbitrary R code to be executed when the Metajags code is compiled.
This expression should return a quoted R expression (e.g. as returned by `quote()`) or a
list of quoted R expressions, which will be treated as Metajags code and compiled.


# <a name="metastan"></a> Metastan: Stan models specified as R code.

Due to the similarity in syntax between Stan and R, Stan models
can be specified in Metajags with few changes, with the exception of
variable declarations (see [differences](#metastan-differences), below).

## Example

Consider the following typical approach (without Metastan) for Stan model specification for
a simple linear regression, which uses a character string to specify the model:

```r
library(rstan)

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

#(some code setting up data_list, etc) 
#...

stan_fit = stan(model_string, data=data_list, ...)
```

With Metastan, we can instead specify the model directly as R code:

```r
library(metabayes)
library(rstan)

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
```

## <a id="metastan-differences"></a> Differences from Stan
The primary difference between Metastan and Stan is in the variable declaration
syntax.

### Variable declaration
The Stan variable declaration syntax is C-like (`type variable`), and
looks like this:

```{c++}
int a;
real<lower=0> x;
vector<lower=-1,upper=1>[3,3] c[10];
```

By contrast, Metastan reverses the declaration order (`variable : type`),
for example:
 
```{r}
a : int
x : real(lower=0)
c[10] : vector(lower=-1,upper=1)[3,3]
```

This syntax has the advantage that the order you read subscripts in is the
same as the order they are declared in (e.g., in the above example, `c`
has subscripts `c[10,3,3]`, _not_ `c[3,3,10]`.
 
### Quoted Stan code: a last resort
While Metastan has syntax to support all current base Stan functionality, future
versions may introduce syntax that is not currently supported. In
that case, you can always include raw Stan code directly by quoting it as a string.
For example:

```r
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
        "y ~ normal(alpha + beta * x, sigma)"
    }
)
```

This results in the same model from above: in this case, `"y ~ normal(alpha + beta * x, sigma)"` is
included directly as raw Stan code. This is recommended **only as a last resort**, as
this code is not parsed by Metastan. That means, for example, that any variable names
included only in string expressions will not be identified by Metastan (functionality
that may be used in the future to automatically pull data from the R environment).

## Metaprogramming extensions to Stan

Metastan includes a few simple metaprogramming statements not found in base Stan. These
are evaluated once, when the Metastan model is compiled.

### `IF` function

The `IF` function may be used for conditional compilation in Metastan (note
that, unlinke Metajags, the `if` statement is not used for conditional compilation 
in Metastan, because Stan actually supports `if` statements):

```r
IF(R_expression, {
    #metastan code (executed if true)
}, {
    #metastan code (executed if false)
})
```

The second clause (executed when false) is optional.

`R_expression` is an R expression that is evaluated _immediately
when the Metastan specification is compiled_; if it is `TRUE`, the first 
block of Metastan code is included in the specification, if it is `FALSE`, the
second block is included (or nothing, if the second clause is omitted). 

In other words, the `R_expression` is evaluated only once (when the model is compiled). 
This statement is useful for conditionally including/excluding parts of the model specification.

### `R` statement
`R(R_expression)` allows arbitrary R code to be executed when the Metastan code is compiled.
This expression should return a quoted R expression (e.g. as returned by `quote()`) or a
list of quoted R expressions, which will be treated as Metastan code and compiled.


# Problems

Should you encounter any issues with this package, contact Matthew Kay
(<mjskay@uw.edu>). If you have found a bug, please file it [here]
(https://github.com/mjskay/metajags/issues/new) with minimal code to reproduce
the issue.

