DROP TABLE IF EXISTS fbd_us_without_satellite_jun2018_v1 CASCADE;
CREATE TABLE fbd_us_without_satellite_jun2018_v1 (
  log_rec_no bigint,
  provider_id bigint,
  frn bigint,
  provider_name text,
  dba_name text,
  holding_company_name text,
  hoco_num bigint,
  hoco_final text,
  state_abbr text,
  block_code text,
  tech_code bigint,
  consumer boolean,
  max_ad_down double precision,
  max_ad_up double precision,
  business boolean,
  max_cir_down double precision,
  max_cir_up double precision
);
\copy fbd_us_without_satellite_jun2018_v1 from 'fbd_us_without_satellite_jun2018_v1.csv' with csv header encoding 'WIN1252'
