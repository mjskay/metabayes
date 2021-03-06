# Tests for metastatements
# 
# Author: mjskay
###############################################################################

library(testthat)
library(metabayes)

context("meta statements")

test_that("metajags if statements compile correctly in the parent environment", {
        a <<- NULL
        a = TRUE
        model = metajags({
                if (a) {
                    b ~ dnorm(0, 10)
                }
                else {
                    g ~ dgamma(1, 1)
                }
            })
        
        expect_equal(code(model),
"model {
    
    b ~ dnorm(0,10);
}")
        expect_equal(model$model$symbols, "b")
        
        
        a = FALSE
        model = metajags({
                if (a) {
                    b ~ dnorm(0, 10)
                }
                else {
                    g ~ dgamma(1, 1)
                }
            })        
        
        expect_equal(code(model),
"model {
    
    g ~ dgamma(1,1);
}")
    })


test_that("metastan IF statements compile correctly in the parent environment", {
        a <<- NULL
        a = TRUE
        model = metastan(
            model = {
                IF (a, {
                    b ~ normal(0, 10)
                },
                {
                    g ~ gamma(1, 1)
                })
            })
        
        expect_equal(code(model),
"model {
    
    b ~ normal(0,10);
}")
        expect_equal(model$model$symbols, "b")
        
        
        a = FALSE
        model = metastan(
            model = {
                IF (a, {
                    b ~ normal(0, 10)
                },
                {
                    g ~ gamma(1, 1)
                })
            })        
        
        expect_equal(code(model),
"model {
    
    g ~ gamma(1,1);
}")
    })

test_that("FALSE IF / if statements with empty else clauses do not introduce empty statements", {
        model = metastan(model = IF(FALSE, x))
        expect_equal(code(model),
"model {
}")

        model = metajags(model = if(FALSE) x)
        expect_equal(code(model),
"model {
}")
    })

test_that("R statements compile correctly in the parent environment", {
        a <<- NULL
        a = 5
        model = metajags({
                a <- 3
                z ~ dnorm(R(a * 7), 10)
            })
        
        expect_equal(code(model),
"model {
    a <- 3;
    z ~ dnorm(35,10);
}")
        expect_true(setequal(model$model$symbols, c("a","z")))
        
        model = metajags({
                z ~ R(quote(dnorm(h, 10)))
            })
        
        expect_equal(code(model),
"model {
    z ~ dnorm(h,10);
}")
        expect_true(setequal(model$model$symbols, c("h","z")))
        
    })

test_that("R() statements returning a list become statement blocks", {
        model = metajags(R(list(
            quote(a <- 3),
            quote(z ~ dnorm(7, 10))))
        )
        
        expect_equal(code(model),
"model {
    a <- 3;
    z ~ dnorm(7,10);
}")
        expect_true(setequal(model$model$symbols, c("a","z")))
    })

test_that("R() statements returning a list with one quoted R language object are compiled into an expression", {
        model = metajags({ R(list(quote(dnorm(0,1)))) })
        
        expect_equal(code(model),
"model {
    dnorm(0,1);
}")
    })
