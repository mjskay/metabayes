# Tests for extract_samples
# 
# Author: mjskay
###############################################################################

library(testthat)
library(plyr)
library(dplyr)
library(tidyr)
library(tidybayes)


test_that("a simple metajags model compiles correctly", {
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

        expect_equal(model$code, 
"model {
    for (i in 1 : n) {
        mu[i] <- b[1] + b[2] * x[i]
        y[i] ~ dnorm(mu[i],tau)
    }
    b[1] ~ dnorm(0,10)
    b[2] ~ dnorm(0,10)
    tau ~ dgamma(0.01,0.01)
}")
        expect_true(setequal(model$symbols, c("i", "n", "mu", "b", "x", "y", "tau")))
    })

test_that("a metajags model with %c% compiles correctly", {
        model = metajags_model({
                b ~ dnorm(0, 10) %c% T(0,)
            })

        expect_equal(model$code,
"model {
    b ~ dnorm(0,10) T(0,)
}")
        expect_equal(model$symbols, "b")
    })

test_that("if statements compile correctly in the parent environment", {
        a = TRUE
        model = metajags_model({
                if (a) {
                    b ~ dnorm(0, 10)
                }
                else {
                    g ~ dgamma(1, 1)
                }
            })
        
        expect_equal(model$code,
"model {
    
    b ~ dnorm(0,10)
}")
        expect_equal(model$symbols, "b")

        
        a = FALSE
        model = metajags_model({
                if (a) {
                    b ~ dnorm(0, 10)
                }
                else {
                    g ~ dgamma(1, 1)
                }
            })        
        
expect_equal(model$code,
"model {
    
    g ~ dgamma(1,1)
}")
    })


test_that("R statements compile correctly", {
        a = 5
        model = metajags_model({
                a <- 3
                z ~ dnorm(R(a * 7), 10)
            })
        
        expect_equal(model$code,
"model {
    a <- 3
    z ~ dnorm(35,10)
}")
        expect_true(setequal(model$symbols, c("a","z")))

        model = metajags_model({
                z ~ R(quote(dnorm(h, 10)))
            })
        
        expect_equal(model$code,
"model {
    z ~ dnorm(h,10)
}")
        expect_true(setequal(model$symbols, c("h","z")))
            
    })


