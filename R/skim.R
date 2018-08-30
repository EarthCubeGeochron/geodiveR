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
#' # Using the results of a gddMatch:
#' coords <- gddMatch(con,
#'                    table = 'sentences',
#'                    col = 'words',
#'                    pattern = '[\\{,][-]?[1]?[0-9]{1,2}\\.[0-9]{1,}[,]?[NESWnesw],',
#'                    name = "decdeg",
#'                    rows = TRUE)
#'
#' DT::datatable(skim(coords, setseed=0.5, clean = 'replace'), )
#'
#' dates <- gddMatch(con,
#'                    table = 'sentences',
#'                    col = 'words',
#'                    pattern = '(\\d+(?:[.]\\d+)*),((?:-{1,2})|(?:to)),(\\d+(?:[.]\\d+)*),([a-zA-Z]+,BP),',
#'                    name = "decdeg",
#'                    rows = TRUE)
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

  if(!is.null(setseed)) {
    assertthat::see_if(findInterval(setseed, -1:1,
                                   leftmost.open = TRUE,
                                   rightmost.closed = TRUE) == 1,
                    msg = "The random seed must be between -1 and 1.")
  }

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
      output <- cleanWords(output)
    }
    return(output)
  }

  if (clean == TRUE & 'words' %in% colnames(x)) {
    x$words <- cleanWords(x$words)
  }

  return(x)
}

#' @export
skim.PostgreSQLConnection <- function(x, table,
  column = NULL, n = 10,
  clean = TRUE, randomize = TRUE,
  setseed = NULL) {

  words <- NULL

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
        dplyr::mutate(words = cleanWords(words))
    }
    if (clean == 'keep') {
      query_result <- query_result %>%
        dplyr::mutate(cleanWords = cleanWords(words))
    }
  }

  return(query_result)
}

#' @export
skim.gddMatch <- function(x, table,
                           column = NULL, n = 10,
                           clean = TRUE, randomize = TRUE,
                           setseed = NULL) {

  # For proper checks, otherwise the check assumes there's a global variable.
  words <- NULL

  if (!is.null(x$rows)) {
    if(!is.null(column)) {
      assertthat::see_if(column %in% colnames(x$rows),
                         msg = "Named column is not in the table.")
      cols <- column
    } else {
      cols <- colnames(x$rows)
    }

    if(!is.null(setseed)) {
      set.seed(setseed)
    }

    if(randomize == TRUE) {
      rn <- sample(nrow(x$rows), n)
    } else {
      rn <- 1:n
    }

    query_result <- x$rows[rn, ] %>% select(cols)

    if ('words' %in% cols) {
      if (clean == 'replace') {
        query_result <- query_result %>%
          dplyr::mutate(words = cleanWords(words))
      }
      if (clean == 'keep') {
        query_result <- query_result %>%
          dplyr::mutate(cleanWords = cleanWords(words))
      }
    }

    return(query_result)

  } else {
    message("Skim requires at least one gddMatch element to have stored rows.")
  }
}
