#! /bin/bash

# get connection parameters
source .env

for i in *.geojson
do
  ogr2ogr -lco precision=NO -nlt PROMOTE_TO_MULTI -overwrite \
    PG:"dbname=${PGDATABASE}" $i
done
