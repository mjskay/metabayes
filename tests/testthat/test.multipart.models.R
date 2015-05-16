# Tests for extract_samples
# 
# Author: mjskay
###############################################################################

library(testthat)
library(metabayes)

context("multipart models")

test_that("a model with multiple sub-parts compiles correctly", {
    refmodel = metajags(dnorm(0,1))
    expect_equal(code(refmodel),
"model {dnorm(0,1)
}")

    model = metajags(model = dnorm(0,1))
    expect_equal(code(model), code(refmodel))
    
    model = metajags(model = dnorm(0,1), data=x ~ y, foo={a <- 5; x = 7})
    expect_equal(code(model),
"data {x ~ y
}

model {dnorm(0,1)
}

foo {
    a <- 5;
    x <- 7;
}")
    })
