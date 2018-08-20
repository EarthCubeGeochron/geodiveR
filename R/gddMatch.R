#' @title Build matches
#' @param con A database connection to the GDD database.
#' @param table The table of interest.
#' @param col The table column.
#' @param pattern A Postgres-compliant regex pattern. \url{https://www.postgresql.org/docs/9.3/static/functions-matching.html}.
#' @param boolean Do you want a boolean match returned?
#' @param name The name used to identify the query.
#' @importFrom DBI sqlInterpolate dbGetQuery
#' @export
#' @examples
#' library(geodiveR)
#' library(DBI)
#'   con <- dbConnect(drv = "PostgreSQL",
#'                    user = "postgres",
#'                    password = "postgres",
#'                    host = "localhost",
#'                    port = "5432",
#'                    dbname = "deepdive")
#'
#'  july_sent <- gddMatch(con = con,
#'                        table = 'sentences',
#'                        col = 'words',
#'                        pattern = 'July',
#'                        name = "JulyQuery")
#'

gddMatch <- function(con, table, col, pattern, boolean = TRUE, name) {
  sql_rows <- paste0("SELECT * FROM ", table, " WHERE ", col, " ~ ?pattern")
  row_query <- DBI::sqlInterpolate(con, sql_rows, pattern = pattern)
  result <- DBI::dbGetQuery(con, row_query)

  if (boolean == TRUE) {
    sql_bool <- paste0("SELECT ", col, " ~ ?pattern FROM ", table, " AS ", name)
    bool_query <- DBI::sqlInterpolate(con, sql_bool, pattern = pattern)
    bool_result <-  DBI::dbGetQuery(con, bool_query)

    result <- list(query = row_query,
                   rows = result,
                   boolean = bool_result)
    return(result)
  }

  result <- list(query = row_query,
                 rows = result)

  return(result)
}
