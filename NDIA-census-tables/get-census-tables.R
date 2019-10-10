# install the package if we need it
if (!require("tidycensus")) install.packages("tidycensus")

# libraries
library(tidyverse)
library(tidycensus)

# get the list of all the 2017 ACS five-year variables `tidycensus` knows
census_variables <- tidycensus::load_variables(2017, "acs5", cache = TRUE)
readr::write_csv(census_variables, path = "~/Documents/census_variables.csv")

# we just want the internet-relevant variables - see
# <https://www.digitalinclusion.org/home-internet-maps/>
internet_variables <- grep("^B280", census_variables$name, value = TRUE)

# load the FIPS code table
data("fips_codes")
readr::write_csv(fips_codes, path = "~/Documents/fips_codes.csv")
fips_codes <- fips_codes %>% dplyr::filter(state_code < 60) # only actual states

# an empty tibble - will have the data when we're done
internet_stats <- tibble::tibble()

# we have to get the data one state at a time
for (state in unique(fips_codes$state)) {
  print(paste("fetching", state))
  internet_stats <- internet_stats %>%
    dplyr::bind_rows(tidycensus::get_acs(
      geography = "tract", variables = internet_variables, state = state
    ))
}

# adjust the column names
names(internet_stats) <- c("geoid", "name", "variable", "estimate", "moe_90pct")

# save as CSV
readr::write_csv(
  internet_stats %>% dplyr::select(-NAME),
  path = "~/Documents/internet_stats.csv"
)
# save the tract names
tract_names <- internet_stats %>% select(geoid, name) %>% unique()
readr::write_csv(tract_names, path = "~/Documents/tract_names.csv")
