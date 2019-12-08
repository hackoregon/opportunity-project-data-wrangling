# libraries
library(tidyverse)
library(sf)

# for (itable in c(demographic_tables, internet_tables)) {
for (itable in c(demographic_tables, "B28002", "B28010")) {

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
