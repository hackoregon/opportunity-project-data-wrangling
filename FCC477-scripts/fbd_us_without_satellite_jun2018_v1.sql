DROP TABLE IF EXISTS fbd_us_without_satellite_jun2018_v1 CASCADE;
CREATE TABLE fbd_us_without_satellite_jun2018_v1 (
LogRecNo text,
FRN text,
ProviderName text,
DBAName text,
HoldingCompanyName text,
HocoNum text,
HocoFinal text,
StateAbbr text,
BlockCode text,
TechCode text,
Consumer text,
MaxAdDown text,
MaxAdUp text,
Business text,
MaxCIRDown text,
MaxCIRUp text
);
\copy fbd_us_without_satellite_jun2018_v1 from 'fbd_us_without_satellite_jun2018_v1.csv' with csv header
