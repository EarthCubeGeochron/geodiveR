#' @title Combine gddMatch Queries
#' @param x A \code{gddMatch} object returned by the \code{gddMatch} function.
#' @param ... More \code{gddMatch} elements.
#' @param rows A boolean (TRUE/FALSE), should the actual text rows be added to the resulting object?
#'
#' @export
and <- function(x, ...) {
  UseMethod('and')
}

#' @export
and.gddMatch <- function(x, ..., rows = FALSE) {

  gdd_objects <- list(...)

  obj_classes <- sapply(gdd_objects, function(x) "gddMatch" %in% class(x) )

  assertthat::see_if(all(obj_classes),
                     msg = "All `and` elements must be of class `gddMatch`")

  boolean <- data.frame(x$boolean,
                        sapply(gdd_objects, function(x)x$boolean))

  query <- c(x$query,
             sapply(gdd_objects, function(x) x$query))

  names(query) <- colnames(boolean)

  if (class(x$rows) == 'NULL') {
    rows <- list(NULL)
    for (i in 1:length(gdd_objects)) {
      rows[[length(rows) + 1]] <- gdd_objects[[i]]$rows
    }

    names(rows) <- colnames(boolean)
  } else {
    for (i in 1:length(gdd_objects)) {
      x$rows[[length(x$rows) + 1]] <- gdd_objects[[i]]$rows
    }
    rows <- x$rows
  }

  output <- list(query = query,
              rows = rows,
              boolean = boolean)
  class(output) <- c("gddMatch", "list")

  return(output)

}
