delete from tree_link l
where
( select tree_type from tree_node n join tree_arrangement a on n.tree_arrangement_id = a.id where n.id = l.supernode_id ) = 'U'
;

update tree_arrangement set node_id = null where tree_type = 'U';

delete from tree_node n
where
( select tree_type from tree_arrangement a where n.tree_arrangement_id = a.id  ) = 'U';

delete from tree_arrangement where tree_type = 'U';

alter table tree_arrangement add base_arrangement_id int8 references arrangement.id;

alter table tree_arrangement add base_arrangement_id int8 references tree_arrangement;

alter table tree_arrangement add constraint tree_type <> 'U' or base_arrangement_id is not null;

alter table tree_arrangement
  add constraint work_trees_have_base_trees check (tree_type <> 'U' or base_arrangement_id is not null);


create index idx_node_current_name_a on tree_node(name_id, tree_arrangement_id) where replaced_at_id is null;
create index idx_node_current_name_b on tree_node(name_id, tree_arrangement_id) where next_node_id is null;
create index idx_node_current_instance_a on tree_node(instance_id, tree_arrangement_id) where replaced_at_id is null;
create index idx_node_current_instance_b on tree_node(instance_id, tree_arrangement_id) where next_node_id is null;
