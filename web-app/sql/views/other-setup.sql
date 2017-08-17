--other setup
ALTER TABLE instance
  ADD CONSTRAINT citescheck CHECK (cites_id IS NULL OR cited_by_id IS NOT NULL);

ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION f_unaccent(TEXT)
  RETURNS TEXT AS
$func$
SELECT unaccent('unaccent', $1)
$func$ LANGUAGE SQL IMMUTABLE SET search_path = public, pg_temp;

CREATE INDEX name_lower_f_unaccent_full_name_like
  ON name (lower(f_unaccent(full_name)) varchar_pattern_ops);
CREATE INDEX ref_citation_text_index
  ON reference USING GIN (to_tsvector('english' :: REGCONFIG, f_unaccent(
      coalesce((citation) :: TEXT, '' :: TEXT))));

-- pg_trgm indexs for like and regex queries NSL-1773
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX name_lower_full_name_gin_trgm
  ON name USING GIN (lower(full_name) gin_trgm_ops);
CREATE INDEX name_lower_simple_name_gin_trgm
  ON name USING GIN (lower(simple_name) gin_trgm_ops);
CREATE INDEX name_lower_unacent_full_name_gin_trgm
  ON name USING GIN (lower(f_unaccent(full_name)) gin_trgm_ops);
CREATE INDEX name_lower_unacent_simple_name_gin_trgm
  ON name USING GIN (lower(f_unaccent(simple_name)) gin_trgm_ops);

-- new tree indexes
DROP INDEX IF EXISTS parent_element_index;
CREATE INDEX parent_element_index
  ON tree_element (parent_version_id, parent_element_id);

DROP INDEX IF EXISTS previous_element_index;
CREATE INDEX previous_element_index
  ON tree_element (previous_version_id, previous_element_id);

INSERT INTO db_version (id, version) VALUES (1, 24);
