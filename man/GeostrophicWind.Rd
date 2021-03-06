% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GeostrophicWind.R
\name{GeostrophicWind}
\alias{GeostrophicWind}
\title{Calculate geostrophic winds}
\usage{
GeostrophicWind(gh, lon, lat, cyclical = "guess", g = 9.8)
}
\arguments{
\item{gh}{geopotential height}

\item{lon}{longitude in degrees}

\item{lat}{latitude in degrees}

\item{cyclical}{boundary condition for longitude (see details)}

\item{g}{acceleration of gravity}
}
\value{
A named list with vectors for the zonal and meridional component of geostrophic
wind.
}
\description{
Geostrophic wind from a geopotential height field.
}
\details{
If \code{cyclical = "guess"} (the default) the function will try to guess if \code{lon}
covers the whole globe and set cyclical conditions accordingly. For more
predictable results, set the boundary condition explicitly.
}
\examples{
data(geopotential)
geopotential <- data.table::copy(geopotential)
geopotential[date == date[1], c("u", "v") := GeostrophicWind(gh, lon, lat)]
library(ggplot2)
ggplot(geopotential[date == date[1]], aes(lon, lat)) +
    geom_contour(aes(z = gh)) +
    geom_vector(aes(dx = u, dy = v), skip = 2)

}
\seealso{
Other meteorology functions: \code{\link{Derivate}},
  \code{\link{EOF}}, \code{\link{WaveFlux}},
  \code{\link{thermodynamics}}, \code{\link{waves}}
}
\concept{meteorology functions}
