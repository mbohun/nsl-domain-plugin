drop table tree_value_uri;

create table tree_value_uri (
  id int8 default nextval('nsl_global_seq') not null,
  lock_version int8 default 0 not null,
  description varchar(2048),
  is_multi_valued boolean default false not null,
  is_resource boolean default false not null,
  label varchar(20) not null,
  link_uri_id_part varchar(255) not null,
  link_uri_ns_part_id int8 not null,
  node_uri_id_part varchar(255) not null,
  node_uri_ns_part_id int8 not null,
  root_id int8 not null,
  sort_order int4 not null,
  title varchar(50) not null,
  primary key (id)
);

create index link_uri_index on tree_value_uri (link_uri_id_part, link_uri_ns_part_id, root_id);

create index node_uri_index on tree_value_uri (node_uri_id_part, node_uri_ns_part_id, root_id);

alter table if exists tree_value_uri
  add constraint FK_ds3bc89iy6q3ts4ts85mqiys
foreign key (link_uri_ns_part_id)
references tree_uri_ns;

alter table if exists tree_value_uri
  add constraint FK_djkn41tin6shkjuut9nam9xvn
foreign key (node_uri_ns_part_id)
references tree_uri_ns;

alter table if exists tree_value_uri
  add constraint FK_nw785lqesvg8ntfaper0tw2vs
foreign key (root_id)
references tree_arrangement;

insert into TREE_VALUE_URI (
  root_id,
  link_uri_ns_part_id,
  link_uri_id_part,
  node_uri_ns_part_id,
  node_uri_id_part,
  label, title, is_multi_valued, is_resource, sort_order
)
values (
  (select id from tree_arrangement where label='APC'),
  (select id from tree_uri_ns where label = 'apc-voc'), 'distribution',
  (select id from tree_uri_ns where label = 'apc-voc'), 'distributionString',
  'apc-distribution', 'APC Distribution',
  false, false, 1
);

insert into TREE_VALUE_URI (
  root_id,
  link_uri_ns_part_id,
  link_uri_id_part,
  node_uri_ns_part_id,
  node_uri_id_part,
  label, title, is_multi_valued, is_resource, sort_order
) values (
  (select id from tree_arrangement where label='APC'),
  (select id from tree_uri_ns where label = 'apc-voc'), 'comment',
  (select id from tree_uri_ns where label = 'xs'), 'string',
  'apc-comment',
  'APC Comment',
  false, false, 1
);


