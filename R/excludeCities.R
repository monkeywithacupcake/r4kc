#' @title Exclude Cities from Polygon
#'
#' @description Remove cities in Kitsap County from the passed simple features.
#' The resulting sf can be used in st_intersection on other geometries.
#' @param sf_cities simple features of cities
#' @param sf_poly simple features of any polygon
#' @keywords cities
#' @export
#' @examples
#' cities <- sf::read_sf(file.path("data","cities"))
#' outline <- sf::read_sf(file.path("data","outline"))
#' county_no_cities <- excludeCities(st_difference(outline, st_union(cities)))

excludeCitiesFromPolygon <- function(sf_cities, sf_poly){
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop(
      "Package \"sf\" must be installed to use this function.",
      call. = FALSE
    )
  }
  st_difference(sf_poly, st_union(sf_cities))
}
