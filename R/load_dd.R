#' @title Load deepdive dump to SQL database
#' @description Takes a raw SQL file and loads it into a Postgres database.
#' @param con An object returned from \code{dbConnect()}
#' @param bib A bibjson file exported from GeoDeepDive.
#' @param sent A set of parsed sentence files from the NLP output.
#' @param bib_name The name for the bibliography table in the database.
#' @param sent_name The name for the sentence table in the database.
#' @param clean Should rows in an existing database be removed?
#' @importFrom RPostgreSQL dbConnect dbExistsTable dbRemoveTable
#' @importFrom DBI dbCreateTable dbWriteTable
#' @importFrom readr read_file read_delim
#' @importFrom purrrlyr by_row
#' @importFrom dplyr select rename combine bind_rows mutate
#' @importFrom assertthat see_if
#' @importFrom jsonlite fromJSON
#' @importFrom stats na.omit
#' @examples
#' \dontrun{
#' library(geodiveR)
#' library(RPostgreSQL)
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
#'   # Or alternately a string to the file path:
#'   # nlp <- "./data/sentences_nlp352"
#'   # publications <- "./data/bibjson"
#'
#'   load_dd(con, bib = publications, sent = nlp)
#' }
#' @export
load_dd <- function(con, bib, sent,
                    bib_name = 'publications',
                    sent_name = 'sentences',
                    clean = TRUE) {

  `_gddid` <- author <- auth <- gddid <- links <- link <- identifier <- NULL

  assertthat::see_if("PostgreSQLConnection" %in% class(con),
                     msg = "You must provide a valid connection to a postgres database using the dbConnect function in RPostgreSQL.")
  assertthat::see_if("character" %in% class(bib),
                     msg = "The bibliography object must be a character string, either a valid JSON string of a file path.")

  assertthat::see_if("character" %in% class(sent) | "data.frame" %in% class(sent),
                     msg = "The sentence object must be a character string or a data.frame.")

  bib_loader <- jsonlite::fromJSON(bib,
                                   simplifyVector = TRUE,
                                   flatten = TRUE)

  if("character" %in% class(sent) & length(sent) == 1) {
    sentences <- readr::read_delim(sent, delim = '\t',
                                   col_names = FALSE,
                                   progress = FALSE)
  } else {
    sentences <- sent
  }

  colnames(sentences) <- c("gddid", "sentence", "word_index", "words", "parts_of_speech", "named_entity", "lemmas", "dep_paths", "dep_parents")

  core_bib <- bib_loader %>%
    select(which(sapply(bib_loader, class) == 'character')) %>%
    rename(gddid = `_gddid`)


  # This leaves authors, links and identifiers as their own tables.

  toauth <- function(x) {
    data.frame(gddid = x$`_gddid`,
               author = ifelse(length(x$author[[1]]) == 0, NA, x$author[[1]]))
  }

  authors <- bib_loader %>%
    select(`_gddid`, author) %>%
    purrrlyr::by_row(function(x) {
      if(length(x$author[[1]]) == 0) {
        return(data.frame(gddid = x$`_gddid`,
                          name = "NA",
                          stringsAsFactors = FALSE))
      }
      return(data.frame(gddid = x$`_gddid`,
                        name = x$author[[1]],
                        stringsAsFactors = FALSE))
    }, .to = "auth") %>%
    select(auth) %>%
    combine() %>%
    bind_rows()

  ids <- bib_loader %>% mutate(gddid = `_gddid`) %>%
    select(gddid, link, identifier) %>%
    purrrlyr::by_row(function(x) {
      if(length(x$link[[1]]) == 0) {
        links <- data.frame(gddid = x$gddid,
                            type = NA,
                            id = NA,
                            stringsAsFactors = FALSE)
      } else {
        links <- data.frame(gddid = x$gddid,
                            type = x$link[[1]]$type,
                            id = x$link[[1]]$url,
                            stringsAsFactors = FALSE)
      }
      if(length(x$identifier[[1]]) == 0) {
        ids <- data.frame(gddid = x$gddid,
                          type = NA,
                          id = NA,
                          stringsAsFactors = FALSE)
      } else {
        ids <- data.frame(gddid = x$gddid,
                          type = x$identifier[[1]]$type,
                          id = x$identifier[[1]]$id,
                          stringsAsFactors = FALSE)
      }
      return(rbind(links, ids))
    }, .to = "links") %>%
    select(links) %>%
    combine() %>%
    bind_rows() %>%
    na.omit()

  for (i in c(bib_name, sent_name, "authors", "links")) {
    if(dbExistsTable(conn = con, i) & clean == TRUE) {
      dbRemoveTable(conn = con, name = i)
    }
  }

  if(!dbExistsTable(conn = con, bib_name)) {

    message("Creating the `publications` table.")
    dbCreateTable(conn = con,
                  name = bib_name,
                  fields = core_bib)
  }

  dbWriteTable(conn = con,
               name = bib_name,
               value = core_bib,
               append = TRUE,
               row.names = FALSE)


  if(!dbExistsTable(conn = con, "authors")) {
    message("Creating the `authors` table.")
    dbCreateTable(conn = con,
                  name = "authors",
                  fields = authors)
  }

  dbWriteTable(conn = con,
               name = "authors",
               value = authors,
               append = TRUE,
               row.names = FALSE)

  if(!dbExistsTable(conn = con, "links")) {
    message("Creating the `links` table.")
    dbCreateTable(conn = con,
                  name = "links",
                  fields = ids)
  }

  dbWriteTable(conn = con,
               name = "links",
               value = ids,
               append = TRUE,
               row.names = FALSE)

  if(!dbExistsTable(conn = con, sent_name)) {
    message("Creating the `sentences` table.")
    dbCreateTable(conn = con,
                  name = sent_name,
                  fields = sentences)
  }

  dbWriteTable(conn = con,
               name = sent_name,
               value = sentences,
               append = TRUE,
               row.names = FALSE)

  return(con)
}
