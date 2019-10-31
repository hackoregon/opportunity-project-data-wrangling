#! /bin/bash

source .env

# cartographic boundaries
echo "loading cartographic boundaries"
/usr/bin/time ogr2ogr -lco precision=NO -nlt PROMOTE_TO_MULTI -overwrite -t_srs EPSG:4326 \
  PG:"dbname=${PGDATABASE}" cartographic_boundaries.shp
/usr/bin/time psql -f cartographic_boundaries.sql

# census data
/usr/bin/time psql -f fips_codes.sql
/usr/bin/time psql -f census_variables.sql
/usr/bin/time psql -f tract_names.sql
/usr/bin/time psql -f internet_stats.sql
