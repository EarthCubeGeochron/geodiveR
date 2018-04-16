#' Publications associated with NLP DeepDive records.
#'
#' A publication dataset returned from a query to GeoDeepDive (\url{https://geodeepdive.org/}).
#' These records are formatted in a modified bibJSON format.
#'
#' @format A \code{data.frame} with 150 rows and 12 columns.
#' \describe{
#'   \item{publisher}{The publisher of the journal or record.}
#'   \item{title}{The title of the specific bibliographic entry.}
#'   \item{author}{Authors of the record.}
#'   \item{year}{Year of publication.}
#'   \item{number}{Publication number within the volume.}
#'   \item{volume}{Volume of the publication.}
#'   \item{link}{Links to publication.}
#'   \item{_gddid}{Unique GeoDeepDive identifier.}
#'   \item{identifier}{Generally a DOI or other URI.}
#'   \item{type}{Kind of publication.}
#'   \item{pages}{Pages within the volume.}
#'   \item{journal.name}{Journal name.}
#'  }
#'  @source \url{https://geodeepdive.org/}
"publications"
