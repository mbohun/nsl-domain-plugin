alter table tree_arrangement add  owner varchar(255);

alter table tree_arrangement add  working_root_id bigint references tree_node;
