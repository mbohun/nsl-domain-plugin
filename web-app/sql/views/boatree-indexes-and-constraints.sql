-- boatree indexes and constraints
-- this script assumes that we are using POSTGRES

-- Namespace
-- Event
-- Arrangement

alter table tree_arrangement add constraint chk_tree_arrangement_type check (tree_type IN ('E','P','U','Z'));

alter table tree_arrangement add constraint chk_classification_has_label check (
	tree_type not in ('E', 'P')
	or (
		label is not null
	)
);

-- Node

alter table tree_node add constraint chk_arrangement_synthetic_yn check (is_synthetic IN ('N','Y'));
alter table tree_node add constraint chk_internal_type_enum check (internal_type IN ('S','Z','T','D','V'));

alter table tree_node add constraint chk_internal_type_S check ( 
  	internal_type <> 'S'
  	or (
	  		name_uri_ns_part_id is null 
	  	and taxon_uri_ns_part_id is null 
	  	and resource_uri_ns_part_id is null
	  	and literal is null
  	)
);

alter table tree_node add constraint chk_internal_type_T check ( 
  	internal_type <> 'T'
  	or (
	  	literal is null
  	)
);

alter table tree_node add constraint chk_internal_type_D check ( 
  	internal_type <> 'D'
  	or (
	  		name_uri_ns_part_id is null 
	  	and taxon_uri_ns_part_id is null 
	  	and literal is null
  	)
);

alter table tree_node add constraint chk_internal_type_V check ( 
  	internal_type <> 'V'
  	or (
	  		name_uri_ns_part_id is null 
	  	and taxon_uri_ns_part_id is null 
	  	and (
	  		(resource_uri_ns_part_id is not null and literal is null)
	  		or
	  		(resource_uri_ns_part_id is null and literal is not null)
	  	)
  	)
);

alter table tree_node add constraint chk_tree_node_synthetic_yn check (is_synthetic IN ('N','Y'));

alter table tree_node add constraint chk_tree_node_name_matches check (name_id is null or cast(name_id as varchar)=name_uri_id_part);

alter table tree_node add constraint chk_tree_node_instance_matches check (instance_id is null or cast(instance_id as varchar)=taxon_uri_id_part);

-- Link

-- a node may only have one link for each link_seq number
create unique index idx_tree_link_seq on tree_link(supernode_id, link_seq);
alter table tree_link add constraint chk_tree_link_seq_positive CHECK (link_seq >= 1);
alter table tree_link add constraint chk_tree_link_vmethod CHECK (versioning_method IN ('F','V','T'));
alter table tree_link add constraint chk_tree_link_synthetic_yn CHECK (is_synthetic IN ('N','Y'));
alter table tree_link add constraint chk_tree_link_sup_not_end  check (supernode_id <> 0);
alter table tree_link add constraint chk_tree_link_sub_not_end  check (subnode_id <> 0);

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
