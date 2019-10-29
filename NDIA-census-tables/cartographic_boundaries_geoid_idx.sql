DROP INDEX IF EXISTS cartographic_boundaries_geoid_idx CASCADE;
CREATE INDEX cartographic_boundaries_geoid_idx
ON cartographic_boundaries (geoid);
