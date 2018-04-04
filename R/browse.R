#' @title Summarize publications
#' @description A quick view method for looking at publication data from the GeoDeepDive publications.
#' @param x One of, a vector of character \code{gddid}s from GeoDeepDive, or a \code{data.frame} with columns \code{gddid} and \code{words}.
#' @param words A vector of sentences, similar to the GDD corpus \code{words} column.
#' @param corpus The full GDD corpus of which \code{x} is expected to be a subset.
#' @param pubs The bibliographic information for the GDD dataset.
#' @importFrom dplyr left_join
#' @example \dontrun{
#' subset <- sample(nrow(nlp), 100)
#' browse(x = nlp$`_gddid`[subset],
#'        pubs = publications,
#'        words = nlp$word[subset])
#' }
#' @export

browse <- function(x, corpus = NULL, pubs = NULL, words = NULL) {

  # Programming notes:
  # I want to build this so we can pass in a data.frame either formatted as a corpus,
  # returning the sentence, a publication ID and

  clean_words <- function(x) {
    gsub("[(${)(}^)]", "", x) %>%                # Curly brakets
      gsub("(,([\\;\\:\\%]),)","\\2 ", .) %>%
      gsub("(([^\"]),([^\"]))", "\\2 \\3", ., perl = TRUE) %>%
      gsub(",\",\",", ", ", .) %>%                 # Commas
      gsub(" \\.", "\\.", .) %>%
      gsub("-LRB-\\s", "\\(", .) %>%
      gsub("(,-RRB-)|(\\s-RRB-)", "\\)", .) %>%
      gsub("(,-RSB-)|(\\s-RSB-)", "\\]", .) %>%
      gsub("-LSB-\\s", "\\[", .)
  }

  # gddid and sentences were passed in:
  if (!is.data.frame(x) & !is.null(words) & is.null(pubs)) {

    # The only thing that's been passed in is the gddid and words.
    assertthat::assert_that(is.character(words) | is.factor(words),
                            msg = "If you don't include the corpus the `words` element must be a character string. ")
    assertthat::assert_that(length(words) == length(x),
                            msg = "Both `words` and `x` must have the same length.")

    output <- data.frame("gddid" = x,
                         words = as.character(words) %>% clean_words)

  }

  if(!is.data.frame(x) & !is.null(pubs) & is.null(words) & is.null(corpus)) {
    assertthat::assert_that(all(x %in% pubs$`_gddid`),
                            msg = "There are unique identifiers passed that are not in the publication table.")

    colnames(pubs)[which(colnames(pubs) == "_gddid")] <- "gddid"

    pubs$doi <- paste0('<a href="http://dx.doi.org/', sapply(pubs$identifier, '[[', 'id'), '">DOI</a>')

    short_pub <- pubs[match(x, pubs$gddid),] %>%
      select(gddid, title, year, journal.name, doi)

    assertthat::assert_that(all(x == short_pub$gddid),
                            msg = "There is a mismatch between publication and selected gddids.")

    output <- data.frame(short_pub) %>% distinct(.keep_all = TRUE)
  }

  if(is.data.frame(x) & !is.null(pubs) & is.null(words) & is.null(corpus)) {

    assertthat::assert_that(any(c('gddid', '_gddid') %in% colnames(x)),
                            msg = "There must be a column either `gddid` or `_gddid` in `x` if `x` is a `data.frame`")

    assertthat::assert_that('word' %in% colnames(x),
                            msg = "There must be a column `words` in `x` if `x` is a `data.frame`")

    if ('_gddid' %in% colnames(x)) {
      colnames(x)[which(colnames(x) == "_gddid")] <- "gddid"
    }

    colnames(pubs)[which(colnames(pubs) == "_gddid")] <- "gddid"

    pubs$doi <- paste0('<a href="http://dx.doi.org/', sapply(pubs$identifier, '[[', 'id'), '">DOI</a>')

    short_pub <- dplyr::left_join(x, pubs, by = "gddid") %>%
      select(gddid, word, title, year, journal.name, doi)

    short_pub$words <- clean_words(short_pub$word)

    short_pub$gddid = paste0('<small><a title ="',
                             short_pub$gddid, '" href = "',
                             short_pub$gddid,'">',
                             substr(short_pub$gddid, 1, 2), '...', substr(short_pub$gddid, 20, 24),
                             '</a></small>')

    output <- data.frame(short_pub)
  }

  out_table <- DT::datatable(output, escape = FALSE, rownames = FALSE) %>%
    DT::formatStyle(columns = 'word',
                    `word-wrap` = 'break-word',
                    `word-break` = 'break-all',
                    `white-space` = 'normal')

  return(out_table)
}
