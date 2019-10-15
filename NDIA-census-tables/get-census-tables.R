# install the package if we need it
if (!require("tidycensus")) install.packages("tidycensus")

# libraries
library(tidyverse)
library(tidycensus)
library(tigris)

# GIS setup
tigris_cache_dir("/Raw/tigris_cache")
readRenviron('~/.Renviron')
Sys.getenv('TIGRIS_CACHE_DIR')
options(tigris_year = 2017)
options(tigris_use_cache = TRUE)

# get the list of all the 2017 ACS five-year variables `tidycensus` knows
census_variables <- tidycensus::load_variables(2017, "acs5", cache = TRUE)
readr::write_csv(census_variables, path = "~/Documents/census_variables.csv")

# we just want the internet-relevant variables - see
# <https://www.digitalinclusion.org/home-internet-maps/>
internet_variables <- grep("^B280", census_variables[["name"]], value = TRUE)

# load the FIPS code table
data("fips_codes")
readr::write_csv(fips_codes, path = "~/Documents/fips_codes.csv")
fips_codes <- fips_codes %>% dplyr::filter(state_code < 60) # only actual states

# pre-fetch the shapefiles
for (state in unique(fips_codes$state)) {
  tigris::tracts(state, cb =TRUE, year = options("tigris_year"))
}

# we have to get the data one state at a time
for (state in unique(fips_codes$state)) {
  print(paste("fetching", state))
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
names(internet_stats) <- c("geoid", "name", "variable", "estimate", "moe_90pct")

# save as CSV
readr::write_csv(
  internet_stats %>% dplyr::select(-name),
  path = "~/Documents/internet_stats.csv"
)
# save the tract names
tract_names <- internet_stats %>% select(geoid, name) %>% unique()
readr::write_csv(tract_names, path = "~/Documents/tract_names.csv")
