DROP TABLE IF EXISTS raw_internet_stats CASCADE;
CREATE TEMPORARY TABLE raw_internet_stats (
  geoid text,
  variable text,
  estimate bigint,
  moe_90pct bigint
);
\copy raw_internet_stats from 'internet_stats.csv' with csv header

DROP TABLE IF EXISTS internet_stats CASCADE;
CREATE TABLE internet_stats AS
  SELECT raw_internet_stats.geoid, variable, estimate, moe_90pct,
    wkb_geometry AS cartographic_boundary_4326
  FROM raw_internet_stats
  LEFT JOIN cartographic_boundaries
  ON raw_internet_stats.geoid = cartographic_boundaries.geoid
;
ALTER TABLE internet_stats ADD COLUMN id serial;
ALTER TABLE internet_stats ADD PRIMARY KEY (id);
