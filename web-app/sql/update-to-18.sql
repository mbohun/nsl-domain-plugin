ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

ALTER TABLE tree_arrangement
  ADD COLUMN shared BOOLEAN DEFAULT TRUE;

-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
