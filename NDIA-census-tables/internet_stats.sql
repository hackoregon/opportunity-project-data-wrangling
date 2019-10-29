DROP TABLE IF EXISTS internet_stats CASCADE;
CREATE TABLE internet_stats (
  geoid text,
  name text,
  variable text,
  estimate bigint,
  moe_90pct bigint
);
\copy internet_stats from 'internet_stats.csv' with csv header
ALTER TABLE internet_stats ADD COLUMN id serial;
ALTER TABLE internet_stats ADD PRIMARY KEY (id);
