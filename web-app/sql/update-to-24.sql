-- new tree structure
DROP INDEX IF EXISTS tree_simple_name_index;
DROP INDEX IF EXISTS tree_name_path_index;
DROP INDEX IF EXISTS tree_tree_path_index;
DROP INDEX IF EXISTS tree_synonyms_index;
DROP INDEX IF EXISTS tree_version_element_element_index;
DROP INDEX IF EXISTS tree_version_element_version_index;

ALTER TABLE IF EXISTS name
  DROP CONSTRAINT IF EXISTS FK_whce6pgnqjtxgt67xy2lfo34;

ALTER TABLE IF EXISTS tree
  DROP CONSTRAINT IF EXISTS FK_svg2ee45qvpomoer2otdc5oyc;

ALTER TABLE IF EXISTS tree
  DROP CONSTRAINT IF EXISTS FK_48skgw51tamg6ud4qa8oh0ycm;

ALTER TABLE IF EXISTS tree_version
  DROP CONSTRAINT IF EXISTS FK_tiniptsqbb5fgygt1idm1isfy;

ALTER TABLE IF EXISTS tree_version
  DROP CONSTRAINT IF EXISTS FK_4q3huja5dv8t9xyvt5rg83a35;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_eoywd7l5fhjpjgn461r6ni2ak;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_5sv181ivf7oybb6hud16ptmo5;

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_ufme7yt6bqyf3uxvuvouowhh;

ALTER TABLE IF EXISTS tree_version_element
  DROP CONSTRAINT IF EXISTS FK_80khvm60q13xwqgpy43twlnoe;

DROP TABLE IF EXISTS distribution;
CREATE TABLE distribution (
  id                        INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version              INT8 DEFAULT 0                         NOT NULL,
  description               VARCHAR(100)                           NOT NULL,
  is_doubtfully_naturalised BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_extinct                BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_native                 BOOLEAN DEFAULT FALSE                  NOT NULL,
  is_naturalised            BOOLEAN DEFAULT FALSE                  NOT NULL,
  region                    VARCHAR(10)                            NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree;
CREATE TABLE tree (
  id                            INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version                  INT8 DEFAULT 0                         NOT NULL,
  current_tree_version_id       INT8,
  default_draft_tree_version_id INT8,
  group_name                    TEXT                                   NOT NULL,
  name                          TEXT                                   NOT NULL,
  reference_id                  INT8,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree_version;
CREATE TABLE tree_version (
  id                  INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version        INT8 DEFAULT 0                         NOT NULL,
  draft_name          TEXT                                   NOT NULL,
  log_entry           TEXT,
  previous_version_id INT8,
  published           BOOLEAN DEFAULT FALSE                  NOT NULL,
  published_at        TIMESTAMP WITH TIME ZONE,
  published_by        VARCHAR(100),
  tree_id             INT8                                   NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree_element;
CREATE TABLE tree_element (
  id                  INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version        INT8 DEFAULT 0                         NOT NULL,
  depth               INT4                                   NOT NULL,
  display_html        TEXT                                   NOT NULL,
  excluded            BOOLEAN DEFAULT FALSE                  NOT NULL,
  instance_id         INT8                                   NOT NULL,
  instance_link       TEXT                                   NOT NULL,
  name_element        VARCHAR(255)                           NOT NULL,
  name_id             INT8                                   NOT NULL,
  name_link           TEXT                                   NOT NULL,
  name_path           TEXT                                   NOT NULL,
  parent_element_id   INT8,
  previous_element_id INT8,
  profile             JSONB,
  rank                VARCHAR(50)                            NOT NULL,
  rank_path           JSONB,
  simple_name         TEXT                                   NOT NULL,
  source_element_link TEXT,
  source_shard        TEXT                                   NOT NULL,
  synonyms            JSONB,
  synonyms_html       TEXT                                   NOT NULL,
  tree_path           TEXT                                   NOT NULL,
  updated_at          TIMESTAMP WITH TIME ZONE               NOT NULL,
  updated_by          VARCHAR(255)                           NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS tree_version_element;
CREATE TABLE tree_version_element (
  element_link    TEXT NOT NULL,
  tree_element_id INT8 NOT NULL,
  tree_version_id INT8 NOT NULL,
  PRIMARY KEY (element_link)
);


ALTER TABLE name
  ADD COLUMN family_id INT8;
ALTER TABLE name
  ADD COLUMN name_path TEXT DEFAULT '' NOT NULL;

ALTER TABLE IF EXISTS tree
  ADD CONSTRAINT FK_svg2ee45qvpomoer2otdc5oyc
FOREIGN KEY (current_tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree
  ADD CONSTRAINT FK_48skgw51tamg6ud4qa8oh0ycm
FOREIGN KEY (default_draft_tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_element
  ADD CONSTRAINT FK_eoywd7l5fhjpjgn461r6ni2ak
FOREIGN KEY (parent_element_id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_element
  ADD CONSTRAINT FK_5sv181ivf7oybb6hud16ptmo5
FOREIGN KEY (previous_element_id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_tiniptsqbb5fgygt1idm1isfy
FOREIGN KEY (previous_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_4q3huja5dv8t9xyvt5rg83a35
FOREIGN KEY (tree_id)
REFERENCES tree;

ALTER TABLE IF EXISTS name
  ADD CONSTRAINT FK_whce6pgnqjtxgt67xy2lfo34
FOREIGN KEY (family_id)
REFERENCES name;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_ufme7yt6bqyf3uxvuvouowhh
FOREIGN KEY (tree_element_id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_version_element
  ADD CONSTRAINT FK_80khvm60q13xwqgpy43twlnoe
FOREIGN KEY (tree_version_id)
REFERENCES tree_version;

CREATE INDEX tree_version_element_link_index
  ON tree_version_element (element_link);

CREATE INDEX tree_simple_name_index
  ON tree_element (simple_name);

CREATE INDEX tree_name_path_index
  ON tree_element (name_path);

CREATE INDEX tree_path_index
  ON tree_element (tree_path);

CREATE INDEX tree_version_element_element_index
  ON tree_version_element (tree_element_id);

CREATE INDEX tree_version_element_version_index
  ON tree_version_element (tree_version_id);


CREATE INDEX tree_synonyms_index
  ON tree_element USING GIN (synonyms);

-- import old tree data into the new structure - this will take a while

-- get current classification-root and follow the prev links back to find versions back to jan 2015
DROP FUNCTION IF EXISTS daily_top_nodes( TEXT, TIMESTAMP );
CREATE FUNCTION daily_top_nodes(tree_label TEXT, since TIMESTAMP)
  RETURNS TABLE(latest_node_id BIGINT, year DOUBLE PRECISION, month DOUBLE PRECISION, day DOUBLE PRECISION)
LANGUAGE SQL
AS $$

WITH RECURSIVE treewalk AS (
  SELECT class_root.*
  FROM tree_node class_node
    JOIN tree_arrangement a ON class_node.id = a.node_id AND a.label = tree_label
    JOIN tree_link sublink ON class_node.id = sublink.supernode_id
    JOIN tree_node class_root ON sublink.subnode_id = class_root.id
  UNION ALL
  SELECT node.*
  FROM treewalk
    JOIN tree_node node ON treewalk.prev_node_id = node.id
)
SELECT
  max(tw.id) AS latest_node_id,
  year,
  month,
  day
FROM treewalk tw
  JOIN tree_event event ON tw.checked_in_at_id = event.id
  ,
      extract(YEAR FROM event.time_stamp) AS year,
      extract(MONTH FROM event.time_stamp) AS month,
      extract(DAY FROM event.time_stamp) AS day
WHERE event.time_stamp > since
GROUP BY year, month, day
ORDER BY latest_node_id ASC
$$;

DROP FUNCTION IF EXISTS tree_element_data_from_start_node( BIGINT );
CREATE FUNCTION tree_element_data_from_start_node(root_node BIGINT)
  RETURNS TABLE(tree_id     BIGINT, node_id BIGINT, excluded BOOLEAN, declared_bt BOOLEAN, instance_id BIGINT, name_id BIGINT,
                simple_name TEXT, name_path TEXT, instance_path TEXT, parent_instance_path TEXT, parent_excluded BOOLEAN,
                rank_path   JSONB, depth INT4)
LANGUAGE SQL
AS $$
WITH RECURSIVE treewalk (tree_id, node_id, excluded, declared_bt, instance_id, name_id, simple_name, name_path, instance_path,
    parent_instance_path, parent_excluded, rank_path, depth) AS (
  SELECT
    tree.id                                                                                                          AS tree_id,
    node.id                                                                                                          AS node_id,
    (node.type_uri_id_part <>
     'ApcConcept') :: BOOLEAN                                                                                        AS excluded,
    (node.type_uri_id_part =
     'DeclaredBt') :: BOOLEAN                                                                                        AS declared_bt,
    node.instance_id                                                                                                 AS instance_id,
    node.name_id                                                                                                     AS name_id,
    n.simple_name :: TEXT                                                                                            AS simple_name,
    coalesce(n.name_element,
             '?')                                                                                                    AS name_path,
    CASE WHEN (node.type_uri_id_part <> 'ApcConcept')
      THEN
        'x' || node.instance_id :: TEXT
    ELSE
      node.instance_id :: TEXT
    END                                                                                                              AS instance_path,
    ''                                                                                                               AS parent_instance_path,
    FALSE                                                                                                            AS parent_excluded,
    jsonb_build_object(rank.name, jsonb_build_object('name', n.name_element, 'id', n.id, 'name_link',
                                                     'http://' || host.host_name || '/name/apni/' ||
                                                     n.id)) :: JSONB                                                 AS rank_path,
    1                                                                                                                AS depth
  FROM tree_link link
    JOIN tree_node node ON link.subnode_id = node.id
    JOIN tree_arrangement tree ON node.tree_arrangement_id = tree.id
    JOIN name n ON node.name_id = n.id
    JOIN name_rank rank ON n.name_rank_id = rank.id
    JOIN instance inst ON node.instance_id = inst.id
    JOIN reference ref ON inst.reference_id = ref.id,
    mapper.host host
  WHERE link.supernode_id = root_node
        AND node.internal_type = 'T'
        AND host.preferred = TRUE
  UNION ALL
  SELECT
    treewalk.tree_id                                                                                        AS tree_id,
    node.id                                                                                                 AS node_id,
    (node.type_uri_id_part <>
     'ApcConcept') :: BOOLEAN                                                                               AS excluded,
    (node.type_uri_id_part =
     'DeclaredBt') :: BOOLEAN                                                                               AS declared_bt,
    node.instance_id                                                                                        AS instance_id,
    node.name_id                                                                                            AS name_id,
    n.simple_name :: TEXT                                                                                   AS simple_name,
    treewalk.name_path || '/' || COALESCE(n.name_element,
                                          '?')                                                              AS name_path,
    CASE WHEN (node.type_uri_id_part <> 'ApcConcept')
      THEN
        treewalk.instance_path || '/x' || node.instance_id :: TEXT
    ELSE
      treewalk.instance_path || '/' || node.instance_id :: TEXT
    END                                                                                                     AS instance_path,
    treewalk.instance_path                                                                                  AS parent_instance_path,
    treewalk.excluded                                                                                       AS parent_excluded,
    treewalk.rank_path ||
    jsonb_build_object(rank.name, jsonb_build_object('name', n.name_element, 'id', n.id, 'name_link',
                                                     'http://' || host.host_name || '/name/apni/' ||
                                                     n.id))                                                 AS rank_path,
    treewalk.depth + 1                                                                                      AS depth
  FROM treewalk
    JOIN tree_link link ON link.supernode_id = treewalk.node_id
    JOIN tree_node node ON link.subnode_id = node.id
    JOIN name n ON node.name_id = n.id
    JOIN name_rank rank ON n.name_rank_id = rank.id
    JOIN instance inst ON node.instance_id = inst.id
    JOIN reference REF ON inst.reference_id = REF.id
    ,
    mapper.host host
  WHERE node.internal_type = 'T'
        AND node.tree_arrangement_id = treewalk.tree_id
        AND host.preferred = TRUE
)
SELECT
  tree_id,
  node_id,
  excluded,
  declared_bt,
  instance_id,
  name_id,
  simple_name,
  name_path,
  instance_path,
  parent_instance_path,
  parent_excluded,
  rank_path,
  depth
FROM treewalk
$$;

-- ************ build new tree data *******************

INSERT INTO tree (group_name, name) VALUES ('treebuilder', 'APC');

-- create versions
INSERT INTO tree_version
(id,
 lock_version,
 draft_name,
 log_entry,
 previous_version_id,
 published,
 published_at,
 published_by,
 tree_id)
  (SELECT
     nextval('nsl_global_seq' :: REGCLASS)             AS id,
     0                                                 AS lock_version,
     'import'                                          AS draft_name,
     'import'                                          AS log_entry,
     NULL                                              AS previous_version_id,
     TRUE                                              AS published,
     (year || '-' || month || '-' || day) :: TIMESTAMP AS published_at,
     'import'                                          AS published_by,
     a.id                                              AS tree_id
   FROM daily_top_nodes('APC', '2016-01-01'), tree a
   WHERE a.name = 'APC');

UPDATE tree_version
SET previous_version_id = id - 1
WHERE id > (SELECT min(id)
            FROM tree_version);

UPDATE tree t
SET current_tree_version_id = (SELECT max(id)
                               FROM tree_version v
                               WHERE v.tree_id = t.id)
WHERE name = 'APC';

VACUUM ANALYSE;

-- create elements


DROP INDEX IF EXISTS instance_path_index;
DROP INDEX IF EXISTS parent_instance_path_index;
DROP INDEX IF EXISTS unique_instance_path_index;

DROP TABLE IF EXISTS instance_paths;
CREATE TABLE instance_paths (
    id,
    instance_path,
    parent_instance_path,
    name_path,
    rank_path,
    instance_id,
    name_id,
    excluded,
    declared_bt,
    depth,
    versions_str,
    nodes,
    versions
) AS
  SELECT
    nextval('nsl_global_seq'),
    instance_path,
    parent_instance_path,
    name_path,
    rank_path,
    instance_id,
    name_id,
    excluded,
    declared_bt,
    depth,
    string_agg(v.id :: TEXT, ','),
    jsonb_agg(DISTINCT (node_id)),
    jsonb_agg(v.id)
  FROM daily_top_nodes('APC', '2016-01-01') AS dtn,
    tree_version v,
        tree_element_data_from_start_node(dtn.latest_node_id) AS el_data,
    mapper.host host
  WHERE v.published_at = (dtn.year || '-' || dtn.month || '-' || dtn.day) :: TIMESTAMP
        AND el_data.instance_id IS NOT NULL
        AND host.preferred = TRUE
  GROUP BY instance_path, excluded,
    declared_bt, parent_instance_path, name_path, rank_path, instance_id, name_id,
    depth;

CREATE INDEX instance_path_index
  ON instance_paths (instance_path);
CREATE INDEX parent_instance_path_index
  ON instance_paths (parent_instance_path);
CREATE UNIQUE INDEX unique_instance_path_index
  ON instance_paths (instance_path, excluded);

DROP FUNCTION IF EXISTS synonym_as_html( BIGINT );
CREATE FUNCTION synonym_as_html(instance_id BIGINT)
  RETURNS TABLE(html TEXT)
LANGUAGE SQL
AS $$
SELECT CASE
       WHEN it.nomenclatural
         THEN '<nom>' || synonym.full_name_html || ' <type>' || it.name || '</type></nom>'
       WHEN it.taxonomic
         THEN '<tax>' || synonym.full_name_html || ' <type>' || it.name || '</type></tax>'
       WHEN it.misapplied
         THEN '<mis>' || synonym.full_name_html || ' <type>' || it.name || '</type> by <citation>' ||
              cites_ref.citation_html
              ||
              '</citation></mis>'
       ELSE ''
       END
FROM Instance i,
  Instance syn_inst
  JOIN instance_type it ON syn_inst.instance_type_id = it.id
  JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
  JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
  ,
  NAME synonym
WHERE syn_inst.cited_by_id = i.id
      AND i.id = instance_id
      AND synonym.id = syn_inst.name_id
ORDER BY it.nomenclatural DESC, it.taxonomic DESC, it.misapplied DESC, cites_ref.year ASC;
$$;

DROP FUNCTION IF EXISTS synonyms_as_html( BIGINT );
CREATE FUNCTION synonyms_as_html(instance_id BIGINT)
  RETURNS TEXT
LANGUAGE SQL
AS $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_as_html(instance_id) AS html;
$$;

SELECT coalesce(synonyms_as_html(738442), '<synonyms></synonyms>');

DROP FUNCTION IF EXISTS profile_as_jsonb( BIGINT );
CREATE FUNCTION profile_as_jsonb(source_instance_id BIGINT)
  RETURNS JSONB
LANGUAGE SQL
AS $$
SELECT jsonb_object_agg(key.name, jsonb_build_object(
    'value', note.value,
    'created_at', note.created_at,
    'created_by', note.created_by,
    'updated_at', note.updated_at,
    'updated_by', note.updated_by,
    'source_link', 'http://' || host.host_name || '/instanceNote/apni/' || note.id
))
FROM instance i
  JOIN instance_note note ON i.id = note.instance_id
  JOIN instance_note_key key ON note.instance_note_key_id = key.id
  ,
  mapper.host host
WHERE i.id = source_instance_id AND host.preferred = TRUE;
$$;

DROP FUNCTION IF EXISTS synonyms_as_jsonb( BIGINT );
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT)
  RETURNS JSONB
LANGUAGE SQL
AS $$
SELECT jsonb_object_agg(synonym.simple_name, jsonb_build_object(
    'type', it.name,
    'name_id', synonym.id,
    'name_link', 'http://' || host.host_name || '/name/apni/' || synonym.id,
    'full_name_html', synonym.full_name_html,
    'nom', it.nomenclatural,
    'tax', it.taxonomic,
    'mis', it.misapplied,
    'cites', cites_ref.citation_html
))
FROM Instance i,
  Instance syn_inst
  JOIN instance_type it ON syn_inst.instance_type_id = it.id
  JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
  JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
  ,
  name synonym,
  mapper.host host
WHERE i.id = instance_id
      AND syn_inst.cited_by_id = i.id
      AND synonym.id = syn_inst.name_id
      AND host.preferred = TRUE;
$$;

INSERT INTO tree_element
(id,
 lock_version,
 excluded,
 display_html,
 synonyms_html,
 instance_id,
 instance_link,
 name_id,
 name_link,
 parent_element_id,
 previous_element_id,
 profile,
 synonyms,
 rank,
 rank_path,
 simple_name,
 name_element,
 tree_path,
 name_path,
 depth,
 source_shard,
 updated_at,
 updated_by
)
  (SELECT
     ipath.id                                                                                  AS id,
     0 :: BIGINT                                                                               AS lock_version,
     ipath.excluded                                                                            AS excluded,
     '<data>' || n.full_name_html || '<citation>' || ref.citation_html || '</citation></data>' AS display_html,
     coalesce(synonyms_as_html(ipath.instance_id), '<synonyms></synonyms>')                    AS synonyms_html,
     ipath.instance_id :: BIGINT                                                               AS instance_id,
     'http://' || host.host_name || '/instance/apni/' || ipath.instance_id                     AS instance_link,
     ipath.name_id :: BIGINT                                                                   AS name_id,
     'http://' || host.host_name || '/name/apni/' || ipath.name_id                             AS name_link,
     coalesce(parent_ipath.id, NULL)                                                           AS parentelementid,
     NULL                                                                                      AS previouselementid,
     profile_as_jsonb(ipath.instance_id)                                                       AS profile,
     synonyms_as_jsonb(ipath.instance_id)                                                      AS synonyms,
     rank.name                                                                                 AS rank,
     ipath.rank_path                                                                           AS rank_path,
     n.simple_name                                                                             AS simple_name,
     coalesce(n.name_element, '?')                                                             AS name_element,
     ipath.instance_path                                                                       AS tree_path,
     ipath.name_path                                                                           AS name_path,
     ipath.depth                                                                               AS depth,
     'APNI'                                                                                    AS source_shard,
     now()                                                                                     AS updated_at,
     'import'                                                                                  AS updated_by
   FROM instance_paths ipath
     JOIN name n ON ipath.name_id = n.id
     JOIN name_rank rank ON n.name_rank_id = rank.id
     JOIN instance i ON ipath.instance_id = i.id
     JOIN reference ref ON i.reference_id = ref.id
     LEFT OUTER JOIN instance_paths parent_ipath
       ON ipath.parent_instance_path = parent_ipath.instance_path
     ,
     mapper.host host
   WHERE host.preferred = TRUE);

-- remove declared BTs by making the children point to the next parent up.

UPDATE tree_element child_el
SET parent_element_id = par_el.parent_element_id
FROM instance_paths ipath
  JOIN tree_element par_el ON par_el.id = ipath.id
WHERE child_el.parent_element_id = par_el.id
      AND ipath.declared_bt = TRUE;

DELETE FROM tree_element
WHERE tree_element.id IN (SELECT ipath.id
                          FROM instance_paths ipath
                          WHERE ipath.declared_bt);

-- link tree_elements to versions

INSERT INTO tree_version_element (element_link, tree_version_id, tree_element_id)
  SELECT
    'http://' || host.host_name || '/tree/' || v.id || '/' || ipath.id,
    v.id,
    ipath.id
  FROM instance_paths ipath, tree_version v, mapper.host host
  WHERE host.preferred = TRUE
        AND ipath.versions @> to_jsonb(v.id)
        AND exists(SELECT 1
                   FROM tree_element e
                   WHERE e.id = ipath.id);

-- set the tree_path to tree elements instead of instance path

WITH RECURSIVE walk (element_id, tree_path) AS (
  SELECT
    id        AS element_id,
    '/' || id AS tree_path
  FROM tree_element
  WHERE parent_element_id IS NULL
  UNION ALL
  SELECT
    e.id                          AS element_id,
    walk.tree_path || '/' || e.id AS tree_path
  FROM walk, tree_element e
  WHERE e.parent_element_id = walk.element_id

)
UPDATE tree_element element
SET tree_path = walk.tree_path
FROM walk
WHERE element.id = walk.element_id;

VACUUM ANALYSE;

-- *************** end tree creation ***************

-- set all the existing name paths and family from APC tree
UPDATE name n
SET name_path = '', family_id = NULL;

UPDATE name name
SET family_id = fam.id,
  name_path   = element.name_path
FROM
  tree_element element
  JOIN tree_version_element tvte ON element.id = tvte.tree_element_id
  JOIN tree ON tvte.tree_version_id = tree.current_tree_version_id AND tree.name = 'APC'
  LEFT OUTER JOIN name fam ON fam.id = (element.rank_path -> 'Familia' ->> 'id') :: BIGINT
  ,
  Instance i,
  Instance s,
  name synonym
WHERE name.id = s.name_id
      AND (s.cited_by_id = i.id OR s.id = i.id) AND i.id = element.instance_id
      AND synonym.id = i.name_id;

-- 88888 repeatedly do this until all names have been joined to an APC parent (6 times as of writing)
DROP FUNCTION IF EXISTS join_non_apc_names_back_to_apc_names();
CREATE FUNCTION join_non_apc_names_back_to_apc_names()
  RETURNS VOID AS $$
DECLARE
BEGIN
  LOOP
    UPDATE name n
    SET name_path = parent.name_path || '/' || coalesce(n.name_element, '?'),
      family_id   = parent.family_id
    FROM (SELECT DISTINCT (name_id)
          FROM instance) AS apni_names,
      name_type,
      name parent
    WHERE n.id = name_id
          AND name_type.id = n.name_type_id
          AND name_type.scientific
          AND n.name_path = ''
          AND n.parent_id IS NOT NULL
          AND parent.id = n.parent_id
          AND parent.name_path <> '';
    IF NOT FOUND
    THEN
      RETURN;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT join_non_apc_names_back_to_apc_names();

DROP FUNCTION join_non_apc_names_back_to_apc_names();

-- set any family that hasn't got the family set to itself
UPDATE name n
SET family_id = n.id
FROM name_rank rank
WHERE n.name_rank_id = rank.id
      AND rank.name = 'Familia'
      AND family_id IS NULL;

-- Repeatedly look at parent name to see if it has a family set and use that until we update none
-- this uses names that don't have instances because some names with instances have name parents that do not have instances
-- after this there are about 56 names (ranked family and below) with instances that don't have a family. see NSL-2440
-- TODO THIS IS PROBABLY WRONG and there has been discussion around how to do this better.
DROP FUNCTION IF EXISTS link_back_missing_family_names();
CREATE FUNCTION link_back_missing_family_names()
  RETURNS VOID AS $$
DECLARE
BEGIN
  LOOP
    UPDATE name n
    SET family_id = parent.family_id
    FROM name parent
    WHERE n.parent_id = parent.id
          AND n.family_id IS NULL
          AND parent.family_id IS NOT NULL;
    IF NOT FOUND
    THEN
      RETURN;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT link_back_missing_family_names();

DROP FUNCTION link_back_missing_family_names();

-- remove all the notifications caused by the trigger on name changes
delete from notification;

-- drop name_tree_path

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_4kc2kv5choyybkaetmshegbet;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_j4j0kq9duod9gm019pl1xec7c;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_try5dwb6jcy5fngk09bf7f7on;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_sfj3hoevcuni3ak7no6byjp3;

ALTER TABLE IF EXISTS name_tree_path
  DROP CONSTRAINT IF EXISTS FK_3xnmxe5p6ed258euacrfflwrj;

DROP MATERIALIZED VIEW IF EXISTS taxon_view;
DROP MATERIALIZED VIEW IF EXISTS name_view;

DROP TABLE IF EXISTS name_tree_path;

-- version
UPDATE db_version
SET version = 24
WHERE id = 1;

