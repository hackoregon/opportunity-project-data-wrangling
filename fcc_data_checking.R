library(data.table)
library(snakecase)
gc(reset = TRUE)
without_satellite <- data.table::fread(nThread = 2,
  file = "/Raw/OpportunityProject/FCC477/fbd_us_without_satellite_jun2018_v1.csv")
gc(reset = TRUE)
snakecase::to_snake_case(names(without_satellite))
with_satellite <- data.table::fread(nThread = 2,
  file = "/Raw/OpportunityProject/FCC477/fbd_us_with_satellite_jun2018_v1.csv")
gc(reset = TRUE)
snakecase::to_snake_case(names(with_satellite))
