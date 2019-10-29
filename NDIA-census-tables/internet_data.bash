#! /bin/bash

source .env
/usr/bin/time psql -f census_variables.sql
/usr/bin/time psql -f fips_codes.sql
/usr/bin/time psql -f internet_stats.sql
/usr/bin/time psql -f tract_names.sql
