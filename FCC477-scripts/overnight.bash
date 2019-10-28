#! /bin/bash

# this will run overnight
source .env
/usr/bin/time psql -f fbd_us_without_satellite_jun2018_v1.sql
/usr/bin/time psql -f fbd_us_with_satellite_jun2018_v1.sql
