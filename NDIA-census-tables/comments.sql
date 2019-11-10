COMMENT ON TABLE tract_names IS 'Census tract names by tract FIPS code for all tracts in the USA';
COMMENT ON COLUMN tract_names.geoid IS 'primary key - text: the 11-character census tract FIPS code.';
COMMENT ON COLUMN tract_names.name IS 'text: the name of the census tract.';

COMMENT ON TABLE fips_codes IS 'County FIPS codes for all counties / parishes in the USA';
COMMENT ON COLUMN fips_codes.state IS 'text: two-character name for the state / territory, e.g. "AL"';
COMMENT ON COLUMN fips_codes.state_code IS 'text: two-character FIPS code for the state / territory, e.g. "01"';
COMMENT ON COLUMN fips_codes.state_name IS 'text: full name for the state / territory, e.g. "Alabama"';
COMMENT ON COLUMN fips_codes.county_code IS 'text: three-character FIPS code for the county / parish, e.g. "001"';
COMMENT ON COLUMN fips_codes.county IS 'text: full name for the county / parish, e.g. "Autauga County"';
COMMENT ON COLUMN fips_codes.id IS 'primary key - serial';

COMMENT ON TABLE census_variables IS 'Variable name dictionary for all variables in the 2013-2017 ACS dataset';
COMMENT ON COLUMN census_variables.name IS 'primary key - text: the variable name, of the form <table>_<column>.';
COMMENT ON COLUMN census_variables.label IS 'text: a human-readable label for the column';
COMMENT ON COLUMN census_variables.concept IS 'text: the concept of the table';

COMMENT ON TABLE cartographic_boundaries IS 'Cartographic boundaries for all census tracts in the USA, You can ignore all columns except "geoid" and "wkb_geometry".';
COMMENT ON COLUMN cartographic_boundaries.geoid IS 'varchar: the 11-character census tract FIPS code';
COMMENT ON COLUMN cartographic_boundaries.wkb_geometry IS 'geometry(multipolygon, SRID 4326): the boundary of the census tract with FIPS code "geoid"';

COMMENT ON TABLE internet_stats IS 'Internet statistics from the 2013-2017 ACS dataset (tables "B280*")';
COMMENT ON COLUMN internet_stats.geoid IS 'text: the 11-character census tract FIPS code. Joins with "geoid" in "tract_names" and "cartographic_boundaries".';
COMMENT ON COLUMN internet_stats.variable IS 'text: The name of the variable. Joins with "name" in "census_variables".';
COMMENT ON COLUMN internet_stats.estimate IS 'double precision: the estimate of the variable'; 
COMMENT ON COLUMN internet_stats.moe_90pct IS 'double precision: the margin of error (default 90 percent) of the estimate'; 
COMMENT ON COLUMN internet_stats.id IS 'primary key - serial'; 

