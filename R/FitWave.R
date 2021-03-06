#' Fourier transform
#'
#' Perform a fourier transform of the data and return the
#'
#' @param y numeric vector to transform
#' @param k numeric vector of wave numbers
#' @param x numeric vector of locations (in radians)
#' @param amplitude numeric vector of amplitudes
#' @param phase numeric vector of phases
#' @param wave optional list output from `FitWave`
#' @param sum wheter to perform the sum or not (see Details)
#'
#' @return
#' `FitWaves` returns a a named list with components
#' \describe{
#'   \item{k}{wavenumbers}
#'   \item{amplitude}{amplitude of each wavenumber}
#'   \item{phase}{phase of each wavenumber in radians}
#'   \item{r2}{explained variance of each wavenumber}
#' }
#'
#' `BuildField` returns a vector of the same length of x with the reconstructed
#' vector if `sum` is `TRUE` or, instead, a list with components
#' \describe{
#'   \item{k}{wavenumbers}
#'   \item{x}{the vector of locations}
#'   \item{y}{the reconstructed signal of each wavenumber}
#' }
#'
#' @details
#' `FitWave` uses [fft] to make a fourier transform of the
#' data and then returns a list of parameters for each wave number kept.
#' The  amplitude (A), phase (\eqn{\phi}) and wave number (k) satisfy:
#' \deqn{y = \sum A cos((x - \phi)k)}
#' The phase is calculated so that it lies between 0 and \eqn{2\pi/k} so it
#' represents the location (in radians) of the first maximum of each wave number.
#' For the case of k = 0 (the mean), phase is arbitrarily set to 0.
#'
#' `BuildField` is `FitWave`'s inverse. It reconstructs the original data for
#' selected wavenumbers. If `sum` is `TRUE` (the default) it performs the above
#' mentioned sum and returns a single vector. If is `FALSE`, then it returns a list
#' of k vectors consisting of the reconstructed signal of each wavenumber.
#'
#' @examples
#' data(geopotential)
#' library(data.table)
#' # January mean of geopotential height
#' jan <- geopotential[month(date) == 1, .(gh = mean(gh)), by = .(lon, lat)]
#'
#' # Stationary waves for each latitude
#' jan.waves <- jan[, FitWave(gh, 1:4), by = .(lat)]
#' library(ggplot2)
#' ggplot(jan.waves, aes(lat, amplitude, color = factor(k))) +
#'     geom_line()
#'
#' # Build field of wavenumber 1
#' jan[, gh.1 := BuildField(lon*pi/180, wave = FitWave(gh, 1)), by = .(lat)]
#' ggplot(RepeatCircular(jan), aes(lon, lat)) +
#'     geom_contour(aes(z = gh.1, color = ..level..)) +
#'     coord_polar()
#'
#' # Build fields of wavenumber 1 and 2
#' waves <- jan[, BuildField(lon*pi/180, wave = FitWave(gh, 1:2), sum = FALSE), by = .(lat)]
#' waves[, lon := x*180/pi]
#' ggplot(RepeatCircular(waves), aes(lon, lat)) +
#'     geom_contour(aes(z = y, color = ..level..)) +
#'     facet_wrap(~k) +
#'     coord_polar()
#'
#' # Field with waves 0 to 2 filtered
#' jan[, gh.no12 := gh - BuildField(lon*pi/180, wave = FitWave(gh, 0:2)), by = .(lat)]
#' ggplot(RepeatCircular(jan), aes(lon, lat)) +
#'     geom_contour(aes(z = gh.no12, color = ..level..)) +
#'     coord_polar()
#'
#' @name waves
#' @family meteorology functions
#' @aliases BuildField FitWave
#' @export
FitWave <- function(y, k = 1) {
    f <- fft(y)
    l <- length(f)
    f <- (f/l)[1:ceiling(l/2)]
    amp <- Mod(f)
    amp[-1] <- amp[-1]*2
    # amp[1] <- mean(y)
    phase <- -Arg(f)

    # Hago que la fase esté entre 0 y 2/k*pi
    phase[phase < 0] <- phase[phase < 0] + 2*pi
    phase <- phase/(seq_along(phase) - 1)
    phase[1] <- 0

    r <- amp^2/sum(amp[-1]^2)
    r[1] <- 0
    k <- k + 1

    ret <- list(k - 1, amp[k], phase[k], r[k])
    names(ret) <- c("k", "amplitude", "phase", "r2")
    return(ret)
}


#' @rdname waves
#' @export
BuildField <- function(x, amplitude, phase, k,
                       wave = list(k = k, amplitude = amplitude, phase = phase),
                       sum = TRUE) {
    if (sum == TRUE) {
        y <- lapply(seq_along(wave$k),
                    function(i) wave$amplitude[i]*cos((x - wave$phase[i])*wave$k[i]))
        y <- Reduce("+", y)
        return(y)
    } else {
        field <- setDT(expand.grid(x = x, k = wave$k))
        field <- field[wave, on = "k"]
        field[, y := amplitude*cos((x - phase)*k), by = k]
        return(as.list(field[, .(k, x, y)]))
    }
}



#' @format NULL
#' @usage NULL
#' @rdname waves
#' @export
FitQsWave <- function(y, k = 1) {
    .Deprecated("FitWave")
}

#' @format NULL
#' @usage NULL
#' @rdname waves
#' @export
BuildQsField <- function(x, amplitude, phase, k, wave) {
    .Deprecated("BuildField")
}



