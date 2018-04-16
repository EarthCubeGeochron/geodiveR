library(testthat)

test_that("Correct browsing:" {
  data(nlp)
  data(publications)
  expect_is(browse((1:nrow(nlp)), corpus = nlp, pubs = publications), "datatables")
  expect_is(browse((1:nrow(nlp)) %% 3 == 0, corpus = nlp, pubs = publications), "datatables")
  expect_is(browse((1:nrow(nlp)) %% 3 == 0, corpus = nlp, pubs = publications), "datatables")
})
