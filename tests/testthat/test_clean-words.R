library(testthat)

context("Clean the text strings.")
test_that("Correct clean_word parsing:", {
  sentences <- c('{Here,we,present,new,datasets,from}',
                 '{Morphometric,data,were,collected,for,all,measureable,Betula,grains,and,results,for,Ha,´,mundarstajaha,´,ls,have,been,published,-LRB-,Caseldine,\",\",2001,-RRB-,.}')

  expect_true(clean_words('{Here,we,present,new,datasets,from}') == "Here we present new datasets from")

})
