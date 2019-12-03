# libraries
if (!require(janitor)) install.packages("janitor")
if (!require(sf)) install.packages("sf")
if (!require(snakecase)) install.packages("snakecase")
if (!require(tidycensus)) install.packages("tidycensus")
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(tigris)) install.packages("tigris")
library(tidyverse)

# GIS setup
tigris_cache <- "/Work/tigris_cache"
dir.create(tigris_cache, recursive = TRUE)
tigris::tigris_cache_dir(tigris_cache)
readRenviron('~/.Renviron')
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
sf::st_write(
  obj = county_cartographic_boundaries,
  dsn = paste0(output_directory, "/county_cartographic_boundaries.geojson"),
  driver = "GeoJSON",
  delete_dsn = TRUE
)

# for (itable in internet_tables) {
# for (itable in c("B28002", "B28010")) {
for (itable in c("B28002")) {

  geojson_dsn <- paste0(output_directory, "/", itable, ".geojson") # output GeoJSON file

  # we have to get the data one state at a time
  for (istate in unique(fips_codes$state)) {
    work <- try(tidycensus::get_acs(
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
    if (class(work) == "try-error") next

    # clean names
    work <- work %>% janitor::clean_names()
    if (istate == "AL") {
      full_table <- work
    } else {
      full_table <- rbind(full_table, work)
    }
  }
  # sf::st_write(
  #   obj = full_table,
  #   dsn = geojson_dsn,
  #   driver = "GeoJSON",
  #   delete_dsn = TRUE
  # )
}
