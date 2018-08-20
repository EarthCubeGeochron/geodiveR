#' @title Return database level GDD Info
#' @details Return information about the Postgres GDD database.
#' @param con GDD database connection.
#' @return A data.frame
#' @export
#' @examples
#' #' library(geodiveR)
#' library(RPostgreSQL)
#'   con <- dbConnect(drv = "PostgreSQL",
#'                    user = "postgres",
#'                    password = "postgres",
#'                    host = "localhost",
#'                    port = "5432",
#'                    dbname = "deepdive")
#'  summary(con)
#'

summaryGdd <- function(con) {
  assertthat::assert_that("PostgreSQLConnection" %in% class(con),
                          msg = "`con` must be a valid Postgres connesction.")
  tables <- DBI::dbListTables(con) %>%
    purrr::map(function(x) { data.frame(table = x,
                                        fields = DBI::dbListFields(con, x),
                                        stringsAsFactors = FALSE)}) %>%
    dplyr::bind_rows()

  table_info <- unique(tables$table) %>%
    sapply(function(x) {
      rows <- DBI::dbGetQuery(con, paste0("SELECT COUNT(*) FROM ", x))
      return(as.numeric(rows))
    })

  tables$rows <- table_info[match(tables$table, names(table_info))]

  return(tables)

}
