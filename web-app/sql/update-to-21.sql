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

-- version
UPDATE db_version
SET version = 21
WHERE id = 1;
