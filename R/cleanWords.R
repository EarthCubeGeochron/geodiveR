#' @title Clean words
#' @description A function to render the word vector to the OCRed sentence.
#' @param x A vector of NLP words as parsed by GDD, or a database connection.
#' @return A \code{character} vector of length equivalent to \code{x}.
#' @examples
#'   library(geodiveR)
#'   con <- dbConnect(drv = "PostgreSQL",
#'                    user = "postgres",
#'                    password = "postgres",
#'                    host = "localhost",
#'                    port = "5432",
#'                    dbname = "deepdive")
#'
#'   # Using the package's data:
#'   data(nlp)
#'   data(publications)
#'
#'   load_dd(con, bib = publications, sent = nlp)
#'
#' @importFrom DBI dbGetQuery
#' @export

cleanWords <- function(x) {
  UseMethod('cleanWords')
}

#' @export
cleanWords.PostgreSQLConnection <- function(x) {
  words <- dbGetQuery(conn = x,
                      statement = "SELECT words FROM sentences")

  return(cleanWords(words))
}

#' @export
cleanWords.character <- function(x) {

  . <- NULL

  ret <- gsub("[(${)(}^)]", "", x) %>%                # Curly brakets
    gsub("(,([\\;\\:\\%]),)","\\2 ", .) %>%
    gsub("(([^\"]),([^\"]))", "\\2 \\3", ., perl = TRUE) %>%
    gsub(",\",\",", ", ", .) %>%                 # Commas
    gsub(" \\.", "\\.", .) %>%
    gsub("-LRB-\\s", "\\(", .) %>%
    gsub("(,-RRB-)|(\\s-RRB-)", "\\)", .) %>%
    gsub("(,-RSB-)|(\\s-RSB-)", "\\]", .) %>%
    gsub("-LSB-\\s", "\\[", .)

  return(ret)
}
