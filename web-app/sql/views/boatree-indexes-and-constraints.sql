-- boatree indexes and constraints
-- this script assumes that we are using POSTGRES

-- Namespace
-- Event
-- Arrangement

ALTER TABLE tree_arrangement
  ADD CONSTRAINT chk_tree_arrangement_type CHECK (tree_type IN ('E', 'P', 'U', 'Z'));

ALTER TABLE tree_arrangement
  ADD CONSTRAINT chk_classification_has_label CHECK (
  tree_type NOT IN ('E', 'P')
  OR (
    label IS NOT NULL
  )
);

-- workspaces are built on a base classification tree
alter table tree_arrangement
  add constraint chk_work_trees_have_base_trees check (tree_type <> 'U' or base_arrangement_id is not null);

-- Node

ALTER TABLE tree_node
  ADD CONSTRAINT chk_arrangement_synthetic_yn CHECK (is_synthetic IN ('N', 'Y'));
ALTER TABLE tree_node
  ADD CONSTRAINT chk_internal_type_enum CHECK (internal_type IN ('S', 'Z', 'T', 'D', 'V'));

ALTER TABLE tree_node
  ADD CONSTRAINT chk_internal_type_S CHECK (
  internal_type <> 'S'
  OR (
    name_uri_ns_part_id IS NULL
    AND taxon_uri_ns_part_id IS NULL
    AND resource_uri_ns_part_id IS NULL
    AND literal IS NULL
  )
);

ALTER TABLE tree_node
  ADD CONSTRAINT chk_internal_type_T CHECK (
  internal_type <> 'T'
  OR (
    literal IS NULL
  )
);

ALTER TABLE tree_node
  ADD CONSTRAINT chk_internal_type_D CHECK (
  internal_type <> 'D'
  OR (
    name_uri_ns_part_id IS NULL
    AND taxon_uri_ns_part_id IS NULL
    AND literal IS NULL
  )
);

ALTER TABLE tree_node
  ADD CONSTRAINT chk_internal_type_V CHECK (
  internal_type <> 'V'
  OR (
    name_uri_ns_part_id IS NULL
    AND taxon_uri_ns_part_id IS NULL
    AND (
      (resource_uri_ns_part_id IS NOT NULL AND literal IS NULL)
      OR
      (resource_uri_ns_part_id IS NULL AND literal IS NOT NULL)
    )
  )
);

ALTER TABLE tree_node
  ADD CONSTRAINT chk_tree_node_synthetic_yn CHECK (is_synthetic IN ('N', 'Y'));

ALTER TABLE tree_node
  ADD CONSTRAINT chk_tree_node_name_matches CHECK (name_id IS NULL OR cast(name_id AS VARCHAR) = name_uri_id_part);

ALTER TABLE tree_node
  ADD CONSTRAINT chk_tree_node_instance_matches CHECK (instance_id IS NULL OR
                                                       cast(instance_id AS VARCHAR) = taxon_uri_id_part);

-- Link

-- a node may only have one link for each link_seq number
CREATE UNIQUE INDEX idx_tree_link_seq
  ON tree_link (supernode_id, link_seq);
ALTER TABLE tree_link
  ADD CONSTRAINT chk_tree_link_seq_positive CHECK (link_seq >= 1);
ALTER TABLE tree_link
  ADD CONSTRAINT chk_tree_link_vmethod CHECK (versioning_method IN ('F', 'V', 'T'));
ALTER TABLE tree_link
  ADD CONSTRAINT chk_tree_link_synthetic_yn CHECK (is_synthetic IN ('N', 'Y'));
ALTER TABLE tree_link
  ADD CONSTRAINT chk_tree_link_sup_not_end CHECK (supernode_id <> 0);
ALTER TABLE tree_link
  ADD CONSTRAINT chk_tree_link_sub_not_end CHECK (subnode_id <> 0);

-- a name may appear only once as a current name in any tree
-- this makes our trees less general ... but matches how we use them these days
ALTER TABLE tree_node
  ADD CONSTRAINT current_name_only_once
  EXCLUDE (tree_arrangement_id with =, name_id with = )
  WHERE (name_id is not null and replaced_at_id is null);

-- fixing the column ordering in these indexes. Big effects on performance.

DROP INDEX IF EXISTS idx_tree_node_taxon_in;
CREATE INDEX idx_tree_node_taxon_in
  ON tree_node (taxon_uri_id_part, taxon_uri_ns_part_id, tree_arrangement_id);

DROP INDEX IF EXISTS idx_tree_node_name_in;
CREATE INDEX idx_tree_node_name_in
  ON tree_node (name_uri_id_part, name_uri_ns_part_id, tree_arrangement_id);

DROP INDEX IF EXISTS idx_tree_node_resource_in;
CREATE INDEX idx_tree_node_resource_in
  ON tree_node (resource_uri_id_part, resource_uri_ns_part_id, tree_arrangement_id);

DROP INDEX IF EXISTS idx_tree_node_name_id_in;
CREATE INDEX idx_tree_node_name_id_in
  ON tree_node (name_id, tree_arrangement_id);

DROP INDEX IF EXISTS idx_tree_node_instance_id_in;
CREATE INDEX idx_tree_node_instance_id_in
  ON tree_node (instance_id, tree_arrangement_id);

-- indexes to speed up queries against the current tree
DROP INDEX IF EXISTS idx_node_current_name_a;
CREATE INDEX idx_node_current_name_a
  ON tree_node (name_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

DROP INDEX IF EXISTS idx_node_current_name_b;
CREATE INDEX idx_node_current_name_b
  ON tree_node (name_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;

DROP INDEX IF EXISTS idx_node_current_instance_a;
CREATE INDEX idx_node_current_instance_a
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

DROP INDEX IF EXISTS idx_node_current_instance_b;
CREATE INDEX idx_node_current_instance_b
  ON tree_node (instance_id, tree_arrangement_id)
  WHERE next_node_id IS NULL;

DROP INDEX IF EXISTS idx_node_current_a;
CREATE INDEX idx_node_current_a
  ON tree_node (tree_arrangement_id)
  WHERE replaced_at_id IS NULL;

DROP INDEX IF EXISTS idx_node_current_b;
CREATE INDEX idx_node_current_b
  ON tree_node (tree_arrangement_id)
  WHERE next_node_id IS NULL;