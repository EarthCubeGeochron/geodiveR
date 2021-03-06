% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cleanWords.R
\name{cleanWords}
\alias{cleanWords}
\title{Clean words}
\usage{
cleanWords(x)
}
\arguments{
\item{x}{A vector of NLP words as parsed by GDD, or a database connection.}
}
\value{
A \code{character} vector of length equivalent to \code{x}.
}
\description{
A function to render the word vector to the OCRed sentence.
}
\examples{
\dontrun{
  library(geodiveR)
  library(DBI)

  con <- dbConnect(drv = "PostgreSQL",
                   user = "postgres",
                   password = "postgres",
                   host = "localhost",
                   port = "5432",
                   dbname = "deepdive")

  # Using the package's data:
  data(nlp)
  data(publications)

  load_dd(con, bib = publications, sent = nlp)
}
}
