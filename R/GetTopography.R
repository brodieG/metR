#' Get topographic data
#'
#' Retrieves topographic data from ETOPO1 Global Relief Model (see references).
#'
#' @param lon.west,lon.east,lat.north,lat.south latitudes and longitudes of the
#' bounding box in degrees
#' @param resolution numeric vector indicating the desired resolution (in degrees)
#' in the lon and lat directions (maximum resolution is 1 minute)
#' @param cache logical indicating if the results should be saved on disk
#' @param file.dir optional directory where to save and/or retrieve data
#' @param verbose logical indicating whether to print progress
#'
#' @return
#' A data table with height (in meters) for each longitude and latitude.
#'
#' @details
#' Very large requests can take long and can be denied by the NOAA server.
#' If the function fails, try with a smaller bounding box or coarser resolution.
#'
#' Longitude coordinates must be between 0 and 360.
#'
#' @examples
#' \dontrun{
#' topo <- GetTopography(280, 330, 0, -60, resolution = 0.5, verbose = FALSE)
#' library(ggplot2)
#' ggplot(topo, aes(lon, lat)) +
#'     geom_raster(aes(fill = h)) +
#'     geom_contour(aes(z = h), breaks = 0, color = "black", size = 0.3) +
#'     scale_fill_gradient2(low = "steelblue", high = "goldenrod2", mid = "olivedrab") +
#'     coord_quickmap()
#' }
#' @references
#' Inspired on [marmap::getNOAA.bathy].
#'
#' Source: Amante, C. and B.W. Eakins, 2009. ETOPO1 1 Arc-Minute Global Relief Model: Procedures, Data Sources and Analysis. NOAA Technical Memorandum NESDIS NGDC-24. National Geophysical Data Center, NOAA. doi:10.7289/V5C8276M
#'
#' @export
#' @import data.table
GetTopography <- function(lon.west, lon.east, lat.north, lat.south, resolution = 3.5,
                          cache = TRUE, file.dir = tempdir(), verbose = interactive()) {
    d <- 1/60
    if (length(resolution) == 1) resolution[2] <- resolution[1]

    # Check arguments
    if (min(resolution) < 1/60) stop("Resolution can't be smaller than 1 minute.")
    if (lat.north < lat.south) stop("lat.north can't be smaller than lat.south")
    if (lon.west > lon.east) stop("lon.east can't be smaller than lon.west")

    if (any(c(lat.north, lat.south) < -90,
            c(lat.north, lat.south) > 90)) stop("Latitude must be between -90 and 90.")

    # Check antimeridian crossing
    if (lon.west < 180 & lon.east > 180) {
        field.left <- GetTopography(lon.west, 180, lat.north, lat.south,
                                    resolution, cache, file.dir, verbose)
        field.right <- GetTopography(180 + d, lon.east, lat.north, lat.south,
                                     resolution, cache, file.dir, verbose)
        field <- rbind(field.left, field.right)
    } else {
        lon.west <- ConvertLongitude(lon.west, from = 360)
        lon.east <- ConvertLongitude(lon.east, from = 360)

        if (cache == TRUE) {
            # Check cache.
            file.name <- paste0(digest::sha1(paste(lon.west, lon.east, lat.north, lat.south,
                                                   resolution[1], resolution[2], sep = "_")),
                                ".txt")
            file <- file.path(file.dir, file.name)

            files <- list.files(file.dir, full.names = TRUE)
        }
        if (file %in% files & cache == TRUE) {
            if (verbose == TRUE) message("Fetching cached field.")
            field <- data.table::fread(file)[, -1]
        } else {
            # Get data
            url <- .BuildETOPORequest(lon.west, lon.east, lat.north, lat.south,
                                      resolution[1], resolution[2])
            field <- try(data.table::fread(url, col.names = c("lon", "lat", "h"),
                                           showProgress = verbose))

            if (is.error(field)) stop("Failed to fetch file.")

        }
        field[, lon := ConvertLongitude(lon, from = 180)]
        if (cache == TRUE) write.csv(field, file = file)    # cache data
    }
    return(field)
}

.BuildETOPORequest <- function(lon.west, lon.east, lat.north, lat.south, resx, resy) {
    bbox <- paste(lon.west, lat.south, lon.east, lat.north, sep = "," )
    url <- paste0("https://gis.ngdc.noaa.gov/cgi-bin/public/wcs/etopo1.xyz?",
                  "filename=etopo1.xyz&request=getcoverage&version=1.0.0",
                  "&service=wcs&coverage=etopo1&CRS=EPSG:4326&format=xyz",
                  "&resx=", resx, "&resy=", resy, "&bbox=", bbox)
}
