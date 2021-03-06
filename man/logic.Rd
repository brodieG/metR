% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpfunctions.R
\name{logic}
\alias{logic}
\alias{\%~\%}
\alias{Similar}
\alias{\%b\%}
\alias{Between}
\title{Extended logical operators}
\usage{
x \%~\% target

Similar(x, target, tol = Inf)

x \%b\% limits

Between(x, limits, include = c(TRUE, TRUE))
}
\arguments{
\item{x, target, limits}{numeric vectors}

\item{tol}{tolerance for similarity}

\item{include}{logical vector of length 2 (or 1) indicating whether to include
the extreme bounds}
}
\value{
A logical vector of the same length of x.
}
\description{
Extended binary operators for easy subsetting.
}
\details{
\code{\%~\%} can be thought as a "similar" operator. It's a fuzzy version of
\code{\link{\%in\%}} in that returns \code{TRUE} for the element of \code{x}
which is the (first) closest to any element of \code{target}.

\code{Similar} is a functional version of \code{\%~\%} that also has a
\code{tol} parameter that indicates the maximum allowed tolerance.

\code{\%b\%} can be thought as the "between" operator. It returns \code{TRUE}
for each element of \code{x} that is between the minimum and the maximum of
\code{limits}.

\code{Between} is a functional version of \code{\%b\%} that also has an
\code{include} parameter that let's you test for \code{x > lower & x < upper}.
If it's a unitary vector, it will be recycled so that \code{include = TRUE} is
equivalent to \code{include = c(TRUE, TRUE)}.

It's important to note that \link{data.table} already has a
\code{\link[data.table]{between}} function optimized with c code, so these
functions use that implementation if data.table is installed (except for the
case of \code{include[1] != include[2]}, for which data.table has no
implementation yet).
}
\examples{
set.seed(198)
x <- rnorm(100)
x[x \%~\% c(0.3, 0.5, 1)]

# Practical use case: vertical cross-section at
# approximately 36W between 50S and 50N.
cross.lon <- -34 + 360
library(ggplot2)
ggplot(temperature[lon \%~\% cross.lon & lat \%b\% c(-50, 50)],
       aes(lat, lev)) +
    geom_contour(aes(z = air))

}
\seealso{
Other utilities: \code{\link{Anomaly}},
  \code{\link{JumpBy}}, \code{\link{Mag}},
  \code{\link{Percentile}}
}
\concept{utilities}
