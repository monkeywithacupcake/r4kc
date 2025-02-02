# May need to change base url
# have to use arcgis - zip downloads no longer maintained

get_base_url <- function(){
  "https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/"
}
get_dataset_name <- function(data_wanted = "outline"){
  case_when(
    grepl("street|road", data_wanted) ~ "Street_Center_Line",
    grepl("citi|city|uga|urban", data_wanted) ~ "Designated_Urban_Growth_Areas",
    grepl("bocc|commiss", data_wanted) ~ "County_Commissioner_District_Outlines",
    .default = "Kitsap_County_Outline"
  )
}

get_data_details <- function(dname = "Kitsap_County_Outline"){
  qpath <- paste0(get_base_url(), dname, "/FeatureServer/0/?f=json")
  res_json <- httr2::request(qpath) %>%
    req_perform() %>%
    resp_body_json()
  n_rows <- request(paste0(
                get_base_url(), dname,
                "/FeatureServer/0/query?where=1=1&f=json&returnCountOnly=True")) %>%
    req_perform() %>%
    resp_body_json() %>% as_tibble() %>% pull(count)

  details <- list(
    fields = res_json$fields %>% purrr::map_chr(\(x) x$name), # fields returned
    geo_type = res_json$geometryType,
    n_batches = ceiling(as.numeric(n_rows)/res_json$maxRecordCount) # , # this is always /2000
  )

  return(details)
}

#' Get KC Data
#'
#' @param dname string of valid data.
#' Can use `get_dataset_name()` to find it.
#' Or browse `https://kitsap-od-kitcowa.hub.arcgis.com` until you find it.
#'
#' @importFrom sf read_sf
#'
#' @return sf or csv
#' @export
#'
#' @examples
#' outline <- get_kc_data(dname = "Kitsap_County_Outline")
get_kc_data <- function(dname = "Kitsap_County_Outline"){
  end_path <- "/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
  sf::read_sf(paste0(get_base_url(), dname, end_path))
}


