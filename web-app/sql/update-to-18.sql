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

-- delete all workspaces

delete from tree_link l
where
  ( select tree_type from tree_node n join tree_arrangement a on n.tree_arrangement_id = a.id where n.id = l.supernode_id ) = 'U'
;

update tree_arrangement set node_id = null where tree_type = 'U';

delete from tree_node n
where
  ( select tree_type from tree_arrangement a where n.tree_arrangement_id = a.id  ) = 'U';

delete from tree_arrangement where tree_type = 'U';

-- add new field and constraint

alter table tree_arrangement add base_arrangement_id int8 references tree_arrangement;

alter table tree_arrangement
  add constraint chk_work_trees_have_base_trees check (tree_type <> 'U' or base_arrangement_id is not null);

-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
