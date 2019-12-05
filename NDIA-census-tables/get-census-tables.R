# libraries
if (!require(janitor)) install.packages("janitor")
if (!require(sf)) install.packages("sf")
if (!require(snakecase)) install.packages("snakecase")
if (!require(tidycensus)) install.packages("tidycensus")
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(tigris)) install.packages("tigris")
library(tidyverse)
library(sf)

# GIS setup
tigris_cache <- "/Work/tigris_cache"
dir.create(tigris_cache, recursive = TRUE)
options(tigris_year = 2017)
options(tigris_use_cache = TRUE)

# Output area setup
output_directory <- "/Work/acs_2017_internet_data/"
dir.create(output_directory, recursive = TRUE)

# get the list of all the 2017 ACS five-year variables `tidycensus` knows
census_variables <-
  tidycensus::load_variables(2017, "acs5", cache = TRUE)
readr::write_csv(
  census_variables,
  path = paste0(output_directory, "/census_variables.csv")
)
variable_decoder_ring <- census_variables %>% dplyr::mutate(
  column_header = gsub("Estimate!!", "", label) %>%
    snakecase::to_snake_case()
  ) %>% dplyr::select(name, column_header)
readr::write_csv(
  variable_decoder_ring,
  path = paste0(output_directory, "/variable_decoder_ring.csv")
)

# we just want the internet-relevant variables - see
# <https://www.digitalinclusion.org/home-internet-maps/>
internet_variables <-
  grep("^B280", census_variables[["name"]], value = TRUE)
internet_tables <- gsub("_.*$", "", internet_variables) %>%
  unique()

# load the FIPS code table
data("fips_codes")
readr::write_csv(
  fips_codes,
  path = paste0(output_directory, "/fips_codes.csv")
)

# pre-fetch the cartographic boundary shapefiles
# https://www.census.gov/programs-surveys/geography/technical-documentation/naming-convention/cartographic-boundary-file.html
for (state in unique(fips_codes$state)) {
  if (state == "UM") next
  print(paste("fetching cartographic boundary shapefile", state))
  if (state == "AL") {
    tract_cartographic_boundaries <-
      tigris::tracts(state, cb =TRUE, year = options("tigris_year"), class = "sf") %>%
      sf::st_transform(4326) %>%
      janitor::clean_names()
    county_cartographic_boundaries <-
      tigris::counties(state, cb =TRUE, year = options("tigris_year"), class = "sf") %>%
      sf::st_transform(4326) %>%
      janitor::clean_names()
  } else {
    tract_cartographic_boundaries <- rbind(
      tract_cartographic_boundaries,
      tigris::tracts(state, cb =TRUE, year = options("tigris_year"), class = "sf") %>%
        sf::st_transform(4326) %>%
        janitor::clean_names()
    )
    county_cartographic_boundaries <- rbind(
      county_cartographic_boundaries,
      tigris::counties(state, cb =TRUE, year = options("tigris_year"), class = "sf") %>%
        sf::st_transform(4326) %>%
        janitor::clean_names()
    )
  }
}
sf::st_write(
  obj = tract_cartographic_boundaries,
  dsn = paste0(output_directory, "/tract_cartographic_boundaries.geojson"),
  driver = "GeoJSON",
  delete_dsn = TRUE
)
tract_cartographic_boundaries <- tract_cartographic_boundaries %>%
  dplyr::select(geoid, geometry)
sf::st_write(
  obj = county_cartographic_boundaries,
  dsn = paste0(output_directory, "/county_cartographic_boundaries.geojson"),
  driver = "GeoJSON",
  delete_dsn = TRUE
)
county_cartographic_boundaries <- county_cartographic_boundaries %>%
  dplyr::select(geoid, geometry)

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

for (itable in internet_tables) {
# for (itable in c("B28002", "B28010")) {
# for (itable in c("B28002")) {

  tract_layer <- paste0(tolower(itable), "_tract")
  county_layer <- paste0(tolower(itable), "_county")
  tract_dsn <- paste0(output_directory, "/", tract_layer, ".geojson")
  county_dsn <- paste0(output_directory, "/", county_layer, ".geojson")

  # we have to get the data one state at a time
  for (istate in unique(fips_codes$state)) {
    tract_work <- try(tidycensus::get_acs(
      geography = "tract",
      table = itable,
      year = 2017,
      output = "tidy",
      state = istate,
      geometry = FALSE,
      moe_level = 90,
      survey = "acs5"
    ))

    # some states don't have data!
    if (class(tract_work) == "try-error") next

    # clean names
    tract_work <- tract_work %>% janitor::clean_names()

    # collect the state
    if (istate == "AL") {
      tract_long <- tract_work
    } else {
      tract_long <- rbind(tract_long, tract_work)
    }

    county_work <- try(tidycensus::get_acs(
      geography = "county",
      table = itable,
      year = 2017,
      output = "tidy",
      state = istate,
      geometry = FALSE,
      moe_level = 90,
      survey = "acs5"
    ))
    if (class(county_work) == "try-error") next
    county_work <- county_work %>% janitor::clean_names()
    if (istate == "AL") {
      county_long <- county_work
    } else {
      county_long <- rbind(county_long, county_work)
    }

  }

  tract_wide <- tract_long %>%
    dplyr::inner_join(variable_decoder_ring, by = c("variable" = "name")) %>%
    dplyr::select(-moe, -variable) %>%
    tidyr::pivot_wider(names_from = column_header, values_from = estimate)
  tract_wide <- tract_cartographic_boundaries %>% inner_join(tract_wide)
  sf::st_write(
    obj = tract_wide,
    layer = tract_layer,
    dsn = tract_dsn,
    driver = "GeoJSON",
    delete_dsn = TRUE
  )

  county_wide <- county_long %>%
    dplyr::inner_join(variable_decoder_ring, by = c("variable" = "name")) %>%
    dplyr::select(-moe, -variable) %>%
    tidyr::pivot_wider(names_from = column_header, values_from = estimate)
  county_wide <- county_cartographic_boundaries %>% inner_join(county_wide)
  sf::st_write(
    obj = county_wide,
    layer = county_layer,
    dsn = county_dsn,
    driver = "GeoJSON",
    delete_dsn = TRUE
  )

}
