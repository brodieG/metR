% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Interpolate.R
\name{Interpolate}
\alias{Interpolate}
\title{Bilinear inteprolation}
\usage{
Interpolate(formula, x.out, y.out, data = NULL, grid = TRUE)
}
\arguments{
\item{formula}{a formula indicating dependent and independent variables (see Details)}

\item{x.out, y.out}{x and y values where to interpolate (see Details)}

\item{data}{optional data.frame with the data}

\item{grid}{logical indicating if x.out and y.out define a regular grid.}
}
\value{
A data.frame with interpolated values and locations
}
\description{
Uses \link[fields:interp.surface]{fields::interp.surface} to interpolate values defined in a bidimensional
grid with bilinear interpolation.
}
\details{
\code{formula} must be of the form VAR1 | VAR2 ~ X + Y where VAR1, VAR2, etc...
are the names of the variables to interpolate and X and Y the names of the
x and y values, respectively.

If \code{grid = TRUE}, \code{x.out} and \code{y.out} must define the values of a regular
grid. If \code{grid = FALSE}, they define the locations where to interpolate.
}
\examples{
library(data.table)
data(geopotential)
geopotential <- geopotential[date == date[1]]
# new grid
x.out <- seq(0, 360, by = 10)
y.out <- seq(-90, 0, by = 10)

# Interpolate values to a new grid
interpolated <- geopotential[, Interpolate(gh ~ lon + lat, x.out, y.out)]

# Add values to an existing grid
geopotential[, gh.new := Interpolate(gh ~ lon + lat, lon, lat,
                                     data = interpolated, grid = FALSE)$gh]

# Interpolate multiple values
geopotential[, c("u", "v") := GeostrophicWind(gh, lon, lat)]
interpolated <- geopotential[, Interpolate(u | v ~ lon + lat, x.out, y.out)]

}
