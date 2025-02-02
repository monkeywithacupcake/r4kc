library(tidyverse)
library(sf)

fpath <- "https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/Kitsap_County_Outline/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
this <- sf::read_sf(fpath)

fpath <- "https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/Date_of_Sale_Table/FeatureServer/0/query?outSR=4326&f=json&where=(PRICE%20%3E%3D%200%20AND%20PRICE%20%3C%3D%200)%20AND%20(INVALID_CD%20IN%20(%27V%27))&outFields=*"
tmp_tbl <- read_sf(fpath)


# httr2 way
#outSR=4326&f=json
f_url <- get_base_url()
f_name <- "Kitsap_County_Outline"
f_params = list(
  outSR = 4326,
  f = 'json'
)
tmp <- request(f_url) %>%
  req_url_path_append(f_name) %>%
  req_url_path_append("FeatureServer/0/") %>%
  req_url_query(!!!f_params)

#16k features
road_cl <- read_sf("https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/Street_Center_Lines/FeatureServer/0/query?outFields=*&where=1%3D1&outSR=4326&f=json")

library(httr2)
res_json <- request("https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/Kitsap_County_Outline/FeatureServer/0/?f=json") %>%
  req_perform() %>%
  resp_body_json()

res_json$maxRecordCount # this is always 2000
res_json$fields %>% map_chr(\(x) x$name) # fields returned
res_json$geometryType #is esriGeometry?

n_rows <- request("https://services6.arcgis.com/qt3UCV9x5kB4CwRA/arcgis/rest/services/Kitsap_County_Outline/FeatureServer/0//query?where=1=1&f=json&returnCountOnly=True") %>%
  req_perform() %>%
  resp_body_json() %>% as_tibble() %>% pull(count)
ceiling(as.numeric(n_rows)/2000)
# create test data
df <- data.frame(
  v1 = c("a", "b", "c"),
  v2 = c(1, 2, 3),
  v3 = c(TRUE, NA, FALSE),
  v4 = I(list(1, 1:2, 1:3)),
  x = c(0, 0, 0),
  y = c(0, 0 ,0)
) %>%
  sf::st_as_sf(coords = c("x", "y"), crs = 4326)

df %>%
  dplyr::rowwise() %>%
  dplyr::ungroup()

df %>%
  tidyr::drop_na(v3)

st_as_sf(df) %>%
  rowwise() %>%
  ungroup() %>%
  drop_na(v3)

st_as_sf(df) %>%
  group_by(v1) %>%
  drop_na(v3)
