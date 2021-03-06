% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/skim.R
\name{skim}
\alias{skim}
\title{Skim a GDD table}
\usage{
skim(x, table = NULL, column = NULL, n = 10, clean = TRUE,
  randomize = TRUE, setseed = NULL)
}
\arguments{
\item{x}{A database connection or a query result.}

\item{table}{A specific table within the database (if \code{con} is provided).}

\item{column}{A specific column within a \code{table} (optional).}

\item{n}{The number of rows to return}

\item{clean}{Should \code{word} columns (if present) be cleaned using \code{clean_words} ('skip', replace', 'keep')?}

\item{randomize}{Should the rows be a random sample from the larger dataset?}

\item{setseed}{A value between \code{-1.0} and \code{1.0} to set the postgres random seed.}
}
\description{
Examine a random set of rows from a table, or a table subset
}
\examples{
\dontrun{
# Connect to a database:
library(RPostgreSQL)
library(geodiveR)

con <- dbConnect(drv = "PostgreSQL",
                 user = "postgres",
                 password = "postgres",
                 host = "localhost",
                 port = "5432",
                 dbname = "deepdive")

skim(con, 'sentences')

# Using the results of a gddMatch:
coords <- gddMatch(con,
                   table = 'sentences',
                   col = 'words',
                   pattern = '[\\\\\{,][-]?[1]?[0-9]\{1,2\}\\.[0-9]\{1,\}[,]?[NESWnesw],',
                   name = "decdeg",
                   rows = TRUE)

DT::datatable(skim(coords, setseed=0.5, clean = 'replace'), )

dates <- gddMatch(con,
                   table = 'sentences',
                   col = 'words',
                   pattern = paste0('(\\\\d+(?:[.]\\\\d+)*),((?:-\{1,2\})|(?:to)),',
                                    '(\\\\d+(?:[.]\\\\d+)*),([a-zA-Z]+,BP),'),
                   name = "decdeg",
                   rows = TRUE)
}

}
