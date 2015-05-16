# Common tests for meta language code
# 
# Author: mjskay
###############################################################################

library(testthat)
library(metabayes)

context("common meta language")

test_that("quoted strings are included as bare code", {
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

test_that("Function names can be expressions", {
        model = metajags(R(quote(dnorm))(h))

        expect_equal(code(model),
"model {
    dnorm(h);
}")
    })

test_that("Parameter lists can have named arguments", {
        model = metajags(f(a=1))
        expect_equal(code(model),
"model {
    f(a=1);
}")

        model = metajags(f(a=1,b))
        expect_equal(code(model),
"model {
    f(a=1,b);
}")
        model = metajags(f(a,b=7))
        expect_equal(code(model),
"model {
    f(a,b=7);
}")
        model = metajags(f(a=1,b=7))
        expect_equal(code(model),
"model {
    f(a=1,b=7);
}")
})
