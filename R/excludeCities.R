#' @title Exclude Cities from Geometry
#'
#' @description Remove cities in Kitsap County from the passed simple features.
#' The resulting sf can be used in st_intersection on other geometries.
#' It is actually a generic excluding function that returns sf_poly
#' without whatever intersects with sf_cities.
#' It does no geographic interpolation of variables; for example, if sf_poly
#' contained a population figure and was partially excluded, the value for
#' population would be exactly the same as the full polygon.
#' The portion of the geometry remaining is calculated.
#'
#' @param sf_poly simple features of any polygon
#' @param sf_cities simple features of cities
#' @param match_col string identifying the key column
#' @keywords cities
#' @importFrom sf st_difference st_transform st_crs st_union
#' @export
#' @examples
#' cities <- sf::read_sf(file.path("data","cities"))
#' outline <- sf::read_sf(file.path("data","outline"))
#' county_no_cities <- exclude_cities(outline, cities)

exclude_cities <- function(sf_poly, sf_cities, match_col){

  out_sf <- sf::st_difference(sf_poly, sf::st_transform(sf::st_union(sf_cities),
                                          sf::st_crs(sf_poly)))
  out_sf <- add_geometry_portion(sf_big = sf_poly, sf_small = out_sf,
                                   match_col = match_col)
}


#' Add Geometry Portion
#' @description
#' Given a big geometry and a clipped subset, determine the
#' portion of the geometry in big represented in small.
#' Uses geometry type (line, polygon), to assess portion.
#'
#' @param sf_big sf the original sf
#' @param sf_small a clipped version of sf_big for which
#' you want to know the portion of each item that remains from
#' when it was sf_big
#' @param match_col string identifying the key column
#'
#' @importFrom dplyr left_join mutate select
#' @importFrom sf st_area st_length st_drop_geometry
#' @returns sf with a new column size_portion
#' @export
#'
#' @examples
#' \dontrun{
#' out_sf <- add_geometry_portion(sf_poly, out_sf, match_col = "someid")
#' }
add_geometry_portion <- function(sf_big, sf_small,
                                 match_col) {
  big_type <- as.character(st_geometry_type(sf_big))[1]
  small_type <- as.character(st_geometry_type(sf_small))[1]
  if(big_type != small_type){
    message(paste("The types for sf_big", big_type,
                  "and sf_small", small_type,
                  "must be the same. This function assumes",
                  "that sf_small is a portion of sf_big"))
  }
  if(tolower(big_type) %in% c("polygon","mutlipolygon")){
    sf_big <- sf_big %>% dplyr::mutate(bsize = as.numeric(sf::st_area(geometry)))
    sf_small <- sf_small %>% dplyr::mutate(ssize = as.numeric(sf::st_area(geometry)))
  }
  if(tolower(big_type) %in% c("linestring","multilinestring")){
    sf_big <- sf_big %>% mutate(bsize = as.numeric(sf::st_length(geometry)))
    sf_small <- sf_small %>% mutate(ssize = as.numeric(sf::st_length(geometry)))
  }
  sf_out <- sf_small %>%
    dplyr::left_join(select(
      sf::st_drop_geometry(sf_big),
      all_of(c(match_col, "bsize"))),
      by = join_by(!!!match_col)) %>%
    dplyr::mutate(size_portion = ssize/bsize) %>%
    dplyr::select(-ssize, -bsize)
  return(sf_out)
}
