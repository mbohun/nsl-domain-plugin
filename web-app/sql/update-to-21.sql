ALTER TABLE name_status
  ADD COLUMN deprecated BOOLEAN DEFAULT FALSE NOT NULL;

DROP VIEW public.accepted_name_vw;
CREATE VIEW public.accepted_name_vw AS
  SELECT
    accepted.id,
    accepted.simple_name,
    accepted.full_name,
    accepted.full_name_html,
    tree_node.type_uri_id_part AS type_code,
    instance.id                AS instance_id,
    tree_node.id               AS tree_node_id,
    0                          AS accepted_id,
    '' :: CHARACTER VARYING    AS accepted_full_name,
    accepted.name_status_id,
    instance.reference_id,
    accepted.name_rank_id,
    accepted.sort_name,
    0                          AS synonym_type_id,
    0                          AS synonym_ref_id,
    0                          AS citer_instance_id,
    0                          AS cites_instance_id,
    '' :: CHARACTER VARYING    AS cites_instance_type_name,
    FALSE                      AS cites_misapplied,
    0                          AS citer_ref_year,
    0                          AS cites_cites_id,
    0                          AS cites_cites_ref_id,
    0                          AS cites_cites_ref_year
  FROM name accepted
    JOIN instance ON accepted.id = instance.name_id
    JOIN tree_node ON accepted.id = tree_node.name_id
    JOIN tree_arrangement ta ON tree_node.tree_arrangement_id = ta.id
  WHERE ta.label :: TEXT = (((SELECT shard_config.value
                              FROM shard_config
                              WHERE shard_config.name :: TEXT = 'tree label' :: TEXT)) :: TEXT)
        AND tree_node.next_node_id IS NULL
        AND tree_node.checked_in_at_id IS NOT NULL
        AND instance.id = tree_node.instance_id;

DROP VIEW public.accepted_synonym_vw;
CREATE VIEW public.accepted_synonym_vw AS
  SELECT
    name_as_syn.id,
    name_as_syn.simple_name,
    name_as_syn.full_name,
    name_as_syn.full_name_html,
    'synonym' :: CHARACTER VARYING AS type_code,
    citer.id                       AS instance_id,
    tree_node.id                   AS tree_node_id,
    citer_name.id                  AS accepted_id,
    citer_name.full_name           AS accepted_full_name,
    name_as_syn.name_status_id,
    0                              AS reference_id,
    name_as_syn.name_rank_id,
    name_as_syn.sort_name,
    cites.instance_type_id         AS synonym_type_id,
    cites.reference_id             AS synonym_ref_id,
    citer.id                       AS citer_instance_id,
    cites.id                       AS cites_instance_id,
    cites_instance_type.name       AS cites_instance_type_name,
    cites_instance_type.misapplied AS cites_misapplied,
    citer_ref.year                 AS citer_ref_year,
    cites_cites.id                 AS cites_cites_id,
    cites_cites.reference_id       AS cites_cites_ref_id,
    cites_cites_ref.year           AS cites_cites_ref_year
  FROM name name_as_syn
    JOIN instance cites ON name_as_syn.id = cites.name_id
    JOIN instance_type cites_instance_type ON cites.instance_type_id = cites_instance_type.id
    JOIN reference cites_ref ON cites.reference_id = cites_ref.id
    JOIN instance citer ON cites.cited_by_id = citer.id
    JOIN reference citer_ref ON citer.reference_id = citer_ref.id
    JOIN name citer_name ON citer.name_id = citer_name.id
    JOIN tree_node ON citer_name.id = tree_node.name_id
    JOIN tree_arrangement ta ON tree_node.tree_arrangement_id = ta.id
    JOIN instance cites_cites ON cites.cites_id = cites_cites.id
    JOIN reference cites_cites_ref ON cites_cites.reference_id = cites_cites_ref.id
  WHERE ta.label :: TEXT = (((SELECT shard_config.value
                              FROM shard_config
                              WHERE shard_config.name :: TEXT = 'tree label' :: TEXT)) :: TEXT)
        AND tree_node.next_node_id IS NULL
        AND tree_node.checked_in_at_id IS NOT NULL
        AND tree_node.instance_id = citer.id;

-- todo handle grants on these re-created views

-- NSL-2045: support for profile data on trees.

-- the primary keys on these rows are not used as fkeys anywhere else, and so is ok to drop
drop table if exists tree_value_uri;

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

create index by_root_id on tree_value_uri (root_id);

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

GRANT SELECT, INSERT, UPDATE, DELETE ON tree_value_uri TO web;
GRANT SELECT ON tree_value_uri TO read_only;

-- version
UPDATE db_version
SET version = 21
WHERE id = 1;
