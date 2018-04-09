#' @title Clean words
#' @description A function to render the word vector to the OCRed sentence.
#' @param x A vector from the NLP \code{data.frame}
#' @return A \code{character} vector of length equivalent to \code{x}.
#' @export

clean_words <- function(x) {

  ret <- gsub("[(${)(}^)]", "", x) %>%                # Curly brakets
    gsub("(,([\\;\\:\\%]),)","\\2 ", .) %>%
    gsub("(([^\"]),([^\"]))", "\\2 \\3", ., perl = TRUE) %>%
    gsub(",\",\",", ", ", .) %>%                 # Commas
    gsub(" \\.", "\\.", .) %>%
    gsub("-LRB-\\s", "\\(", .) %>%
    gsub("(,-RRB-)|(\\s-RRB-)", "\\)", .) %>%
    gsub("(,-RSB-)|(\\s-RSB-)", "\\]", .) %>%
    gsub("-LSB-\\s", "\\[", .)

  attr(ret, 'input') <- x

  return(ret)

}
