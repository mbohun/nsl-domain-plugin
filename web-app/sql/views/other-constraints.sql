alter table instance ADD CONSTRAINT citescheck check (cites_id is null or cited_by_id is not null);

-- fixing the column ordering in these indexes. Big effects on performance.

DROP INDEX idx_tree_node_taxon_in;
CREATE INDEX idx_tree_node_taxon_in ON tree_node (taxon_uri_id_part, taxon_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_name_in;
CREATE INDEX idx_tree_node_name_in ON tree_node (name_uri_id_part, name_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_resource_in;
CREATE INDEX idx_tree_node_resource_in ON tree_node (resource_uri_id_part, resource_uri_ns_part_id, tree_arrangement_id);

DROP INDEX idx_tree_node_name_id_in;
CREATE INDEX idx_tree_node_name_id_in ON tree_node (name_id, tree_arrangement_id);

DROP INDEX idx_tree_node_instance_id_in;
CREATE INDEX idx_tree_node_instance_id_in ON tree_node (instance_id, tree_arrangement_id);

create index name_lower_f_unaccent_full_name_like on name (lower(f_unaccent(full_name)) varchar_pattern_ops);
