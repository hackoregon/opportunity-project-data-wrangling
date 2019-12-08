# libraries
library(tidyverse)
library(sf)

## Geotag the demographic data
demographic_data <- readr::read_csv(
  paste0(output_directory, "/demographic_data.csv"),
  col_types = cols(
    `Median Income` = col_double(),
    `Poverty Rate` = col_double(),
    `Race: Share Asian / Other` = col_double(),
    `Race: Share Black` = col_double(),
    `Race: Share Hispanic` = col_double(),
    `Race: Share White` = col_double(),
    `Metro Name` = col_character(),
    geoid = col_character()
  )
)
demographic_data <- tract_cartographic_boundaries %>% dplyr::inner_join(demographic_data)
sf::st_write(
  obj = demographic_data,
  dsn = paste0(output_directory, "/demographic_data.geojson"),
  driver = "GeoJSON",
  delete_dsn = TRUE
)
