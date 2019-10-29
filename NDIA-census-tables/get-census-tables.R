# install the package if we need it
if (!require("tidycensus")) install.packages("tidycensus")

# libraries
library(tidyverse)
library(tidycensus)
library(tigris)
library(sp)
library(rgdal)

# GIS setup
tigris_cache_dir("/Raw/OpportunityProject/tigris_cache")
readRenviron('~/.Renviron')
Sys.getenv('TIGRIS_CACHE_DIR')
options(tigris_year = 2017)
options(tigris_use_cache = TRUE)

# Output area setup
output_directory <- "/Raw/OpportunityProject/acs_2017_internet_data/"
unlink(output_directory, force = TRUE, recursive = TRUE)
dir.create(output_directory)

# get the list of all the 2017 ACS five-year variables `tidycensus` knows
census_variables <-
  tidycensus::load_variables(2017, "acs5", cache = TRUE)
readr::write_csv(
  census_variables,
  path = paste0(output_directory, "/census_variables.csv")
)

# we just want the internet-relevant variables - see
# <https://www.digitalinclusion.org/home-internet-maps/>
internet_variables <-
  grep("^B280", census_variables[["name"]], value = TRUE)

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
    cartographic_boundaries <-
      tigris::tracts(state, cb =TRUE, year = options("tigris_year"))

  } else {
    cartographic_boundaries <- rbind(
      cartographic_boundaries,
      tigris::tracts(state, cb =TRUE, year = options("tigris_year"))
    )
  }
}
rgdal::writeOGR(
  cartographic_boundaries,
  dsn = output_directory,
  layer = "cartographic_boundaries",
  driver = "ESRI Shapefile"
)

# we have to get the data one state at a time
for (state in unique(fips_codes$state)) {
  if (state == "AS") next
  if (state == "GU") next
  if (state == "MP") next
  if (state == "UM") next
  if (state == "VI") next
  print(paste("fetching data", state))
  if (state == "AL") {
    internet_stats <- tidycensus::get_acs(
      geography = "tract",
      variables = internet_variables,
      state = state
    )
  } else {
    internet_stats <- dplyr::bind_rows(
      internet_stats,
      tidycensus::get_acs(
        geography = "tract",
        variables = internet_variables,
        state = state
      )
    )
  }
}

# adjust the column names
names(internet_stats) <-
  c("geoid", "name", "variable", "estimate", "moe_90pct")

# save as CSV
readr::write_csv(
  internet_stats %>% dplyr::select(-name),
  path = paste0(output_directory, "/internet_stats.csv")
)

# save the tract names
tract_names <- internet_stats %>% select(geoid, name) %>% unique()
readr::write_csv(
  tract_names,
  path = paste0(output_directory, "/tract_names.csv")
)
