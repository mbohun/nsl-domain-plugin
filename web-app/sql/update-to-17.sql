ALTER TABLE instance_type
  ADD COLUMN has_label VARCHAR(255) NOT NULL DEFAULT 'not set';
ALTER TABLE instance_type
  ADD COLUMN of_label VARCHAR(255) NOT NULL DEFAULT 'not set';

UPDATE instance_type
SET has_label = name
WHERE misapplied = FALSE;
UPDATE instance_type
SET of_label = name || ' of'
WHERE misapplied = FALSE;
UPDATE instance_type
SET has_label = regexp_replace(name, 'misapplied', 'misapplication')
WHERE misapplied = TRUE;
UPDATE instance_type
SET of_label = name || ' to'
WHERE misapplied = TRUE;

ALTER TABLE ref_type
  ADD COLUMN use_parent_details BOOLEAN DEFAULT FALSE NOT NULL;

-- version
UPDATE db_version
SET version = 17
WHERE id = 1;
