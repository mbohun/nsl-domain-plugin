ALTER TABLE tree_arrangement
  ADD COLUMN shared boolean DEFAULT true;

-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
