library(testthat)

context("Checking the data")
test_that("Correct data connected:", {
  data(nlp)
  data(publications)
  expect_equal(nrow(nlp), 87181)
  expect_is(publications, "character")
})
