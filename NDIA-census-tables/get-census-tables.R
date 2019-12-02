# libraries,
install.packages(c(
  "janitor",
  "rgdal",
  "sf",
  "tidycensus",
  "tidyverse",
  "tigris"
))
library(tidyverse)

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

for (itable in internet_tables) {
  # for (itable in c("B28002", "B28010")) {

  geojson_dsn <- paste0(output_directory, "/", itable, ".geojson") # output GeoJSON file

  # we have to get the data one state at a time
  for (istate in unique(fips_codes$state)) {
    work <- try(tidycensus::get_acs(
      geography = "tract",
      table = itable,
      year = 2017,
      output = "wide",
      state = istate,
      geometry = TRUE,
      moe_level = 90,
      survey = "acs5"
    ))

    # some states don't have data!
    if (class(work) == "try-error") next

    # reproject and clean names
    work <- work %>%
      sf::st_transform(crs = 4326) %>%
      janitor::clean_names()
    if (istate == "AL") {
      full_table <- work
    } else {
      full_table <- rbind(full_table, work)
    }
  }
  sf::st_write(
    obj = full_table,
    dsn = geojson_dsn,
    driver = "GeoJSON",
    delete_dsn = TRUE
  )
}
