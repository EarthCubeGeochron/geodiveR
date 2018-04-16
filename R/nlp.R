#' \code{nlp} dataset from GeoDeepDive
#'
#' A dataset returned from a query to GeoDeepDive (\url{https://geodeepdive.org/}) that
#' includes Natural Language Processing elements from the Stanford NLP tools (\url{https://nlp.stanford.edu/}).
#'
#' @format A \code{data.frame} with 87,181 rows and 9 columns.
#' \describe{
#'   \item{_gddid}{Unique identifier for the article within the GDD database.}
#'   \item{sentence}{Unique sentence index within the article.}
#'   \item{wordIndex}{Unique index of unique words within the sentences.}
#'   \item{word}{Sentence within the article, split by commas.}
#'   \item{partofspeech}{Parts of Speech from the Stanford tagger, matching the Penn State Treebank tags: \url{https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html}}
#'   \item{specialclass}{Special classes (numbers, dates, &cetera)}
#'   \item{wordsAgain}{}
#'   \item{wordtype}{Word types, based on universal dependencies (\url{http://universaldependencies.org/introduction.html}).}
#'   \item{wordmodified}{The word (from the word index) modified by the typed word.}
#'  }
#'  @source \url{https://geodeepdive.org/}
"nlp"
