DROP TABLE IF EXISTS internet_stats CASCADE;
CREATE TABLE internet_stats (
  geoid text REFERENCES tract_names(geoid),
  variable text REFERENCES census_variables(name),
  estimate double precision,
  moe_90pct double precision
);
\copy internet_stats from 'internet_stats.csv' with csv header

CREATE INDEX ON internet_stats(geoid, variable);
ALTER TABLE internet_stats ADD COLUMN id serial;
ALTER TABLE internet_stats ADD PRIMARY KEY (id);
