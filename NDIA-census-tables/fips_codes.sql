DROP TABLE IF EXISTS fips_codes CASCADE;
CREATE TABLE fips_codes (
  state text,
  state_code text,
  state_name text,
  county_code text,
  county text
);
\copy fips_codes from 'fips_codes.csv' with csv header
ALTER TABLE fips_codes ADD COLUMN id serial;
ALTER TABLE fips_codes ADD PRIMARY KEY (id);
