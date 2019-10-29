DROP TABLE IF EXISTS census_variables CASCADE;
CREATE TABLE census_variables (
  name text,
  label text,
  concept text
);
\copy census_variables from 'census_variables.csv' with csv header
ALTER TABLE census_variables ADD COLUMN id serial;
ALTER TABLE census_variables ADD PRIMARY KEY (id);
