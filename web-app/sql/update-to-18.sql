ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

ALTER TABLE tree_arrangement
  ADD COLUMN shared BOOLEAN DEFAULT TRUE;

DROP TRIGGER IF EXISTS reference_update
ON author;

CREATE TRIGGER reference_update
AFTER INSERT OR UPDATE OR DELETE ON reference
FOR EACH ROW
EXECUTE PROCEDURE reference_notification();

UPDATE namespace
SET name = 'Algae'
WHERE name = 'AusAlgae';
UPDATE namespace
SET description_html = '(description of <b>Algae</b>)'
WHERE name = 'Algae';
UPDATE namespace
SET rdf_id = 'algae'
WHERE name = 'Algae';

INSERT INTO namespace (id, lock_version, name, description_html, rdf_id)
VALUES (nextval('nsl_global_seq'), 0, 'Lichen', '(description of <b>Lichen</b>)', 'lichen');
INSERT INTO public.namespace (id, lock_version, name, description_html, rdf_id)
VALUES (nextval('nsl_global_seq'), 0, 'Fungi', '(description of <b>Fungi</b>)', 'fungi');

-- indexes to speed up queries against the current tree
CREATE INDEX idx_node_current_name_a
  ON tree_node (name_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

  CREATE INDEX idx_node_current_name_b
  ON tree_node (name_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;
 

CREATE INDEX idx_node_current_instance_a
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;
 

CREATE INDEX idx_node_current_instance_b
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;

CREATE INDEX idx_node_current_a
  ON tree_node (tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

CREATE INDEX idx_node_current_b
  ON tree_node (tree_arrangement_id)
  WHERE next_node_id IS NULL;
-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
