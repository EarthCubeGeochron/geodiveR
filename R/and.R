#' @title Combine gddMatch Queries
#' @param x A \code{gddMatch} object returned by the \code{gddMatch} function.
#' @param ... More \code{gddMatch} elements.
#' @param rows A boolean (TRUE/FALSE), should the actual text rows be added to the resulting object?
#' @description Working towards combining records in GDD.
#' @export
and <- function(x, ..., rows = FALSE) {
  UseMethod('and')
}

#' @title Combine gddMatch Queries
#' @description Combine results from \code{gddMatch} into a single object.
#' @param x A \code{gddMatch} object returned by the \code{gddMatch} function.
#' @param ... More \code{gddMatch} elements.
#' @param rows A boolean (TRUE/FALSE), should the actual text rows be added to the resulting object?
#' @export
and.gddMatch <- function(x, ..., rows = FALSE) {

  gdd_objects <- list(...)

  obj_classes <- sapply(gdd_objects, function(x) "gddMatch" %in% class(x) )

  assertthat::see_if(all(obj_classes),
                     msg = "All `and` elements must be of class `gddMatch`")

  query <- c(x$query,
             sapply(gdd_objects, function(x) x$query))

  names(query) <- c(names(x$boolean),
                    sapply(gdd_objects, function(x) names(x$boolean)))

  boolean <- data.frame(x$boolean,
                        sapply(gdd_objects, function(x) x$boolean))

  if (class(x$rows) == 'NULL') {
    rows <- list(NULL)
    for (i in 1:length(gdd_objects)) {
      rows[[length(rows) + 1]] <- gdd_objects[[i]]$rows
    }

    names(rows) <- colnames(boolean)
  } else {
    if('data.frame' %in% class(x$rows)) {
      x$rows <- list(x$rows)
    }

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
