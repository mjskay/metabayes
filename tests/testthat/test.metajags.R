# Tests for extract_samples
# 
# Author: mjskay
###############################################################################

library(testthat)
library(metabayes)

context("metajags")

test_that("a simple metajags model compiles correctly", {
        model = metajags({
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

        expect_equal(code(model), 
"model {
    for (i in 1 : n) {
        mu[i] <- b[1] + b[2] * x[i];
        y[i] ~ dnorm(mu[i],tau);
    }
    b[1] ~ dnorm(0,10);
    b[2] ~ dnorm(0,10);
    tau ~ dgamma(0.01,0.01);
}")
        expect_true(setequal(model$model$symbols, c("i", "n", "mu", "b", "x", "y", "tau")))
    })

test_that("quoted strings are included as bare JAGS code", {
        model = metajags({
                #core model
                for (i in 1:n) {
                    # latent variable log-linear model
                    "mu[i] <- b[1] + b[2] * x[i]"
                }
            })

        expect_equal(code(model),
"model {
    for (i in 1 : n) {
        mu[i] <- b[1] + b[2] * x[i];
    }
}")
    })

test_that("a metajags model with %c% compiles correctly", {
        model = metajags({
                b ~ dnorm(0, 10) %c% T(0,)
            })

        expect_equal(code(model),
"model {
    b ~ dnorm(0,10) T(0,);
}")
        expect_equal(model$model$symbols, "b")
    })

test_that("Function names can be expressions", {
        model = metajags(R(quote(dnorm))(h))

        expect_equal(code(model),
"model {
    dnorm(h);
}")
    })
