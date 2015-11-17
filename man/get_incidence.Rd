% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/get_incidence.r
\name{get_incidence}
\alias{get_incidence}
\title{Calculate incidence from flusurvey data}
\usage{
get_incidence(data, incidence.column = "ili", aggregation = c("week", "day",
  "month", "year"), denominator = c("active.members", "reports"),
  min.N = 1000)
}
\arguments{
\item{data}{a data table, usually generated by \code{\link{merge_data}}}

\item{incidence.column}{the column which specifices incidence; default: "ili"}

\item{aggregation}{the timescale of aggregation, by default "week"}

\item{denominator}{what to use as denominator, active members or all reports in a week}

\item{min.N}{the minimum denominator, by default 1000}
}
\value{
a data.table with the incidence
}
\description{
This calculates incidence according to a given column in the supplied data.
}
\author{
seb
}
