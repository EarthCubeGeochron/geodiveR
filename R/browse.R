#' @title Summarize publications
#' @description A quick view method for looking at publication data from the GeoDeepDive publications.
#' @param x A vector of numeric \code{gddid}s from GeoDeepDive, a \code{boolean} vector where \code{length(x) == corpus}, or a \code{data.frame} with columns \code{gddid} and \code{words}.
#' @param words A vector of sentences, similar to the GDD corpus \code{words} column.
#' @param corpus The full GDD corpus of which \code{x} is expected to be a subset.
#' @param pubs The bibliographic information for the GDD dataset.
#' @importFrom dplyr left_join
#' @importFrom DT datatable formatStyle
#' @examples \dontrun{
#' # Load in sample data:
#'
#' data(nlp)
#' data(publications)
#'
#' subset <- sample(nrow(nlp), 100)
#'
#' # Return only the publication information, using gddids as the key:
#'
#' browse(x = nlp$`_gddid`[subset],
#'        pubs = publications)
#'
#' # Using a numeric or boolean index of sentences:
#'
#' subset <- sample(nrow(nlp), 100)
#'
#' browse(x = subset,
#'        pubs = publications,
#'        corpus = nlp)
#'
#' subset <- (1:nrow(nlp)) %in% subset
#' browse(x = subset,
#'        pubs = publications,
#'        corpus = nlp)
#' }
#'
#' @export
browse <- function(x, corpus = NULL, pubs = NULL, words = NULL) {
  UseMethod('browse')
}

#' @title Summarize publications
#' @export
browse.logical <- function(x, corpus = NULL, pubs = NULL, ...) {

  assertthat::assert_that(!is.null(pubs),
                          msg = "With a boolean vector you must provide a table of publications.")

  assertthat::assert_that(!is.null(pubs),
                          msg = "With a boolean vector you must provide a table of publications.")

  assertthat::assert_that(length(x) == nrow(corpus),
                          msg = "With a boolean vector the vector and corpus length must be equal.")

  assertthat::assert_that(any(c('gddid', '_gddid') %in% colnames(pubs)),
                          msg = "There must be a column either `gddid` or `_gddid` in `x` if `x` is a `data.frame`")

  x <- (1:nrow(corpus))[x]
  browse(x, corpus, pubs)
}


#' @title Summarize publications
#' @export
browse.numeric <- function(x, corpus = NULL, pubs = NULL, ...) {
  assertthat::assert_that(!is.null(pubs),
                          msg = "With a numeric index you must provide a table of publications.")

  assertthat::assert_that(!is.null(corpus),
                          msg = "With a numeric index you must provide a table of publications.")

  assertthat::assert_that(!max(x) > nrow(corpus),
                          msg = "With a character vector of gddids you must provide a corpus.")

  assertthat::assert_that(any(c('gddid', '_gddid') %in% colnames(pubs)),
                          msg = "There must be a column either `gddid` or `_gddid` in `x` if `x` is a `data.frame`")

  colnames(pubs)[which(colnames(pubs) == "_gddid")] <- "gddid"
  colnames(corpus)[which(colnames(corpus) == "_gddid")] <- "gddid"

  output <- corpus[x, ] %>%
    dplyr::left_join(y = pubs, by = 'gddid')

  output$doi <- paste0('<a href="http://dx.doi.org/', sapply(output$identifier, '[[', 'id'), '">DOI</a>')

  short_out <- output %>%
    dplyr::select('gddid', 'word', 'title', 'year', 'journal.name', 'doi')

  short_out$words <- clean_words(short_out$word)

  short_out$gddid <- paste0('<small><a title ="',
                            short_out$gddid, '" href = "',
                            short_out$gddid,'">',
                            substr(short_out$gddid, 1, 2),
                            '...', substr(short_out$gddid, 20, 24),
                            '</a></small>')

  output <- data.frame(short_out)

  out_table <- DT::datatable(output, escape = FALSE, rownames = FALSE) %>%
    DT::formatStyle(columns = c('title','word'),
                    `word-wrap` = 'break-word',
                    `word-break` = 'break-all',
                    `white-space` = 'normal')

  return(out_table)

}

#' @title Summarize publications
#' @export
browse.character <- function(x, corpus = NULL, pubs = NULL, words = NULL) {
  assertthat::assert_that(!is.null(pubs),
                          msg = "With a character vector of gddids you must provide a table of publications.")

  assertthat::assert_that(any(c('gddid', '_gddid') %in% colnames(pubs)),
                          msg = "There must be a column either `gddid` or `_gddid` in `x` if `x` is a `data.frame`")

  output <- pubs[pubs$`_gddid` %in% x,]

  colnames(pubs)[which(colnames(pubs) == "_gddid")] <- "gddid"

  pubs <- pubs %>% dplyr::filter(gddid %in% x)

  pubs$doi <- paste0('<a href="http://dx.doi.org/', sapply(pubs$identifier, '[[', 'id'), '">DOI</a>')

  short_pub <- pubs %>%
    dplyr::select('gddid', 'title', 'year', 'journal.name', 'doi')

  out_table <- DT::datatable(short_pub, escape = FALSE, rownames = FALSE) %>%
    DT::formatStyle(columns = 'title',
                    `word-wrap` = 'break-word',
                    `word-break` = 'break-all',
                    `white-space` = 'normal')

  return(out_table)

}
