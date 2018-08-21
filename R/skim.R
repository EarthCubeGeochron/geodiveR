#' @title Skim a GDD table
#' @description Examine a random set of rows from a table, or a table subset
#' @param x A database connection or a query result.
#' @param table A specific table within the database (if \code{con} is provided).
#' @param column A specific column within a \code{table} (optional).
#' @param n The number of rows to return
#' @param clean Should \code{word} columns (if present) be cleaned using \code{clean_words} ('skip', replace', 'keep')?
#' @param randomize Should the rows be a random sample from the larger dataset?
#' @param setseed A value between \code{-1.0} and \code{1.0} to set the postgres random seed.
#' @importFrom assertthat see_if
#' @importFrom dplyr mutate
#' @importFrom DBI dbListTables
#' @examples
#' # Connect to a database:
#' library(RPostgreSQL)
#' library(geodiveR)
#'
#' con <- dbConnect(drv = "PostgreSQL",
#'                  user = "postgres",
#'                  password = "postgres",
#'                  host = "localhost",
#'                  port = "5432",
#'                  dbname = "deepdive")
#'
#' skim(con, 'sentences')
#'
#' @export

skim <- function(x,
  table = NULL,
  column = NULL,
  n = 10,
  clean = TRUE,
  randomize = TRUE,
  setseed = NULL) {
  UseMethod('skim')
}

#' @export
skim.data.frame <- function(x, table = NULL,
  column = NULL, n = 10,
  clean = TRUE, randomize = TRUE,
  setseed = NULL) {

  if (randomize == TRUE) {
    if (!is.null(setseed)) {
      set.seed(setseed)
      rows <- sample(nrow(x), n)
    } else {
      rows <- sample(nrow(x), n)
    }
  } else {
    rows <- 1:n
  }

  x <- x[rows, ]

  if (!is.null(column)) {
    assertthat::see_if(column %in% colnames(x), msg = "Named column is not in the provided data.frame.")
    output <- x[ , which(colnames(x) == column)]
    if (clean == TRUE) {
      output <- clean_words(output)
    }
    return(output)
  }

  if (clean == TRUE & 'words' %in% colnames(x)) {
    x$words <- clean_words(x$words)
  }
}

#' @export
skim.PostgreSQLConnection <- function(x, table,
  column = NULL, n = 10,
  clean = TRUE, randomize = TRUE,
  setseed = NULL) {

  assertthat::see_if(!is.null(table),
                     msg = "If `x` is a postgres connection you must supply a table name.")

  assertthat::see_if(table %in% DBI::dbListTables(x),
                     msg = paste0("Currently ", table, " is not a table in the GDD database."))

  if (randomize == TRUE) {
    if (!is.null(setseed)) {
      seed <- paste0("SELECT setseed(", setseed, "); ")
    } else {
      seed <- ""
    }
    rand <- " ORDER BY RANDOM() "
  } else {
    rand <- " "
  }

  if (is.null(column)) {
    query <- paste0(seed, "SELECT * FROM ", table, rand, " LIMIT ", n)
  } else {
    query <- paste0(seed, "SELECT ", column, " FROM ", table, rand, " LIMIT ", n)
  }

  query_result <- DBI::dbGetQuery(x, query)

  if ('words' %in% colnames(query_result)) {
    if (clean == 'replace') {
      query_result <- query_result %>%
        dplyr::mutate(words = clean_words(words))
    }
    if (clean == 'keep') {
      query_result <- query_result %>%
        dplyr::mutate(clean_words = clean_words(words))
    }
  }

  return(query_result)
}
