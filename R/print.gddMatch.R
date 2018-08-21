#' @export
print.gddMatch <- function(x, ...) {

  # If there are multiple gddMatch elements in x (from an and or an or):
  results <- data.frame (queries = as.character(x$query),
                         counts  = colSums(x$boolean),
                         rows    = nrow(x$boolean))

  cat(paste0("This gddMatch contains ", nrow(results), " object",
      ifelse(nrow(results) == 1, "\n", "s\n")))
  print(results)

}
