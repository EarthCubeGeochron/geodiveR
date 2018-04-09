library(testthat)

test_that("Correct clean_word parsing:" {
  sentences <- c('{Here,we,present,new,datasets,from,Tro,¨,llaskagi,\",\",based,on,chironomid-inferred,temperatures,-LRB-,CI-T,-RRB-,\",\",using,subfossil,chironomids,from,the,same,lake,sediments,supplemented,by,pollen,data,.}',
                 '{Morphometric,data,were,collected,for,all,measureable,Betula,grains,and,results,for,Ha,´,mundarstajaha,´,ls,have,been,published,-LRB-,Caseldine,\",\",2001,-RRB-,.}')

  expect_that(clean_words(sentences[1]),
              equals('Here we present new datasets from Tro¨llaskagi, based on chironomid-inferred temperatures (CI-T), using subfossil chironomids from the same lake sediments supplemented by pollen data'))
})
