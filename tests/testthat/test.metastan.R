# Tests for metastan
# 
# Author: mjskay
###############################################################################

library(testthat)
library(metabayes)

context("metastan")

test_that("a simple metastan model compiles correctly", {
        model = metastan(
            data = {
                N : int(lower=0)
                K : int(lower=0)
                x : matrix[N,K]
                y : vector[N]
            },
            parameters = {
                alpha : real
                beta : vector[K]
                sigma: real(lower=0)
            },
            model = {
                y ~ normal(x * beta + alpha, sigma)
            })

        expect_equal(code(model), 
"data {
    int<lower=0> N;
    int<lower=0> K;
    matrix[N,K] x;
    vector[N] y;
}

parameters {
    real alpha;
    vector[K] beta;
    real<lower=0> sigma;
}

model {
    y ~ normal(x * beta + alpha,sigma);
}")
        expect_true(setequal(model$model$symbols, c("x", "y", "alpha", "beta", "sigma")))
    })
