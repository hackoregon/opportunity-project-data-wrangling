SELECT
  blackshare AS "Race: Share Black",
  whiteshare AS "Race: Share White",
  hispshare AS "Race: Share Hispanic",
  asothshare AS "Race: Share Asian / Other",
  medinc AS "Median Income",
  povrate AS "Poverty Rate",
  metroname AS "Metro Name",
  lpad(fips_code_id::text, 11, '0') AS geoid
FROM api_ncdbsampleyearly
WHERE year = 2017
AND povrate IS NOT NULL
ORDER BY fips_code_id;
