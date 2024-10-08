% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/backend-dbplyr__duckdb_connection.R
\name{backend-duckdb}
\alias{tbl_file}
\alias{tbl_function}
\alias{tbl_query}
\alias{simulate_duckdb}
\title{DuckDB SQL backend for dbplyr}
\usage{
tbl_file(src, path, ..., cache = FALSE)

tbl_function(src, query, ..., cache = FALSE)

tbl_query(src, query, ...)

simulate_duckdb(...)
}
\arguments{
\item{src}{A duckdb connection object}

\item{path}{Path to existing Parquet, CSV or JSON file}

\item{...}{Any parameters to be forwarded}

\item{cache}{Enable object cache for Parquet files}

\item{query}{SQL code, omitting the \code{FROM} clause}
}
\description{
This is a SQL backend for dbplyr tailored to take into account DuckDB's
possibilities. This mainly follows the backend for PostgreSQL, but
contains more mapped functions.

\code{tbl_file()} is an experimental variant of \code{\link[dplyr:tbl]{dplyr::tbl()}} to directly access files on disk.
It is safer than \code{dplyr::tbl()} because there is no risk of misinterpreting the request,
and paths with special characters are supported.

\code{tbl_function()} is an experimental variant of \code{\link[dplyr:tbl]{dplyr::tbl()}}
to create a lazy table from a table-generating function,
useful for reading nonstandard CSV files or other data sources.
It is safer than \code{dplyr::tbl()} because there is no risk of misinterpreting the query.
See \url{https://duckdb.org/docs/data/overview} for details on data importing functions.

As an alternative, use \code{dplyr::tbl(src, dplyr::sql("SELECT ... FROM ..."))} for custom SQL queries.

\code{tbl_query()} is deprecated in favor of \code{tbl_function()}.

Use \code{simulate_duckdb()} with \code{lazy_frame()}
to see simulated SQL without opening a DuckDB connection.
}
\examples{
\dontshow{if (duckdb:::TEST_RE2 && rlang::is_installed("dbplyr")) withAutoprint(\{ # examplesIf}
library(dplyr, warn.conflicts = FALSE)
con <- DBI::dbConnect(duckdb(), path = ":memory:")

db <- copy_to(con, data.frame(a = 1:3, b = letters[2:4]))

db \%>\%
  filter(a > 1) \%>\%
  select(b)

path <- tempfile(fileext = ".csv")
write.csv(data.frame(a = 1:3, b = letters[2:4]))

db_csv <- tbl_file(con, path)
db_csv \%>\%
  summarize(sum_a = sum(a))

db_csv_fun <- tbl_function(con, paste0("read_csv_auto('", path, "')"))
db_csv \%>\%
  count()

DBI::dbDisconnect(con, shutdown = TRUE)
\dontshow{\}) # examplesIf}
}
