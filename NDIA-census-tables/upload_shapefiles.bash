#! /bin/bash

echo "creating census_gis schema"
psql --username=${PGUSER} --dbname=${PGDATABASE} --command="DROP SCHEMA IF EXISTS census_gis CASCADE;"
psql --username=${PGUSER} --dbname=${PGDATABASE} --command="CREATE SCHEMA census_gis;"

echo "uploading boundary shapefiles"
for i in cb*shp
do
  echo $i
  ogr2ogr -lco precision=NO -nlt PROMOTE_TO_MULTI -overwrite -t_srs EPSG:4326 \
    PG:"dbname=${PGDATABASE} active_schema=census_gis" $i
done
