DROP TABLE IF EXISTS tract_names CASCADE;
CREATE TABLE tract_names (
  geoid text,
  name text
);
\copy tract_names from 'tract_names.csv' with csv header
ALTER TABLE tract_names ADD PRIMARY KEY (geoid);
