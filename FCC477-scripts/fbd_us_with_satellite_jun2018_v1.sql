DROP TABLE IF EXISTS fbd_us_with_satellite_jun2018_v1 CASCADE;
CREATE TABLE fbd_us_with_satellite_jun2018_v1 (
LogRecNotext,
Provider_Idtext,
FRNtext,
ProviderNametext,
DBANametext,
HoldingCompanyNametext,
HocoNumtext,
HocoFinaltext,
StateAbbrtext,
BlockCodetext,
TechCodetext,
Consumertext,
MaxAdDowntext,
MaxAdUptext,
Businesstext,
MaxCIRDowntext,
MaxCIRUp text
);
\copy fbd_us_with_satellite_jun2018_v1 from 'fbd_us_with_satellite_jun2018_v1.csv' with csv header
