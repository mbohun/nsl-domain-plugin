-- NSL-2347 Add external resources
CREATE TABLE site (
  id           INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version INT8 DEFAULT 0                         NOT NULL,
  created_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  created_by   VARCHAR(50)                            NOT NULL,
  description  VARCHAR(1000)                          NOT NULL,
  name         VARCHAR(100)                           NOT NULL,
  updated_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  updated_by   VARCHAR(50)                            NOT NULL,
  url          VARCHAR(500)                           NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE resource (
  id           INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version INT8 DEFAULT 0                         NOT NULL,
  created_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  created_by   VARCHAR(50)                            NOT NULL,
  path         VARCHAR(2400)                          NOT NULL,
  site_id      INT8                                   NOT NULL,
  updated_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  updated_by   VARCHAR(50)                            NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE instance_resources (
  instance_id INT8 NOT NULL,
  resource_id INT8 NOT NULL,
  PRIMARY KEY (instance_id, resource_id)
);

ALTER TABLE IF EXISTS instance_resources
  ADD CONSTRAINT FK_8mal9hru5u3ypaosfoju8ulpd
FOREIGN KEY (resource_id)
REFERENCES resource;

ALTER TABLE IF EXISTS instance_resources
  ADD CONSTRAINT FK_49ic33s4xgbdoa4p5j107rtpf
FOREIGN KEY (instance_id)
REFERENCES instance;

ALTER TABLE IF EXISTS resource
  ADD CONSTRAINT FK_l76e0lo0edcngyyqwkmkgywj9
FOREIGN KEY (site_id)
REFERENCES site;

CREATE OR REPLACE VIEW instance_resource_vw AS
  SELECT
    site.name                 site_name,
    site.description          site_description,
    site.url                  site_url,
    resource.path             resource_path,
    site.url || resource.path url,
    instance_id
  FROM site
    INNER JOIN resource
      ON site.id = resource.site_id
    INNER JOIN instance_resources
      ON resource.id = instance_resources.resource_id
    INNER JOIN instance
      ON instance_resources.instance_id = instance.id;

-- NSL-464 improve tree performance
ALTER TABLE tree_link
  DROP CONSTRAINT IF EXISTS chk_tree_link_seq_positive;

CREATE OR REPLACE FUNCTION current_workspace_taxonomic_nodes(workspace_id BIGINT)
  RETURNS TABLE(node_id BIGINT, instance_id BIGINT, name_id BIGINT) AS $$
WITH RECURSIVE treewalk AS (
  SELECT
    workspace.node_id             AS node_id,
    NULL :: BIGINT                AS instance_id,
    NULL :: BIGINT                AS name_id,
    workspace.id                  AS workspace_id,
    workspace.base_arrangement_id AS base_id
  FROM tree_arrangement workspace
  WHERE workspace.id = workspace_id
  UNION ALL
  SELECT
    node.id AS node_id,
    node.instance_id,
    node.name_id,
    treewalk.workspace_id,
    treewalk.base_id
  FROM treewalk
    JOIN tree_link link ON link.supernode_id = treewalk.node_id
    JOIN tree_node node ON link.subnode_id = node.id
  WHERE node.next_node_id IS NULL
        AND node.internal_type = 'T'
        AND node.tree_arrangement_id IN (treewalk.workspace_id, treewalk.base_id)
)
SELECT
  node_id,
  instance_id,
  name_id
FROM treewalk
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION draft_nodes_below_this_node(node_id BIGINT)
  RETURNS TABLE(node_id BIGINT) AS $$
WITH RECURSIVE treewalk AS (
  SELECT
    node_id
  UNION ALL
  SELECT
    node.id AS node_id
  FROM treewalk
    JOIN tree_link link ON link.supernode_id = treewalk.node_id
    JOIN tree_node node ON link.subnode_id = node.id
  WHERE node.checked_in_at_id is null
)
SELECT
  node_id
FROM treewalk
$$ LANGUAGE SQL;

-- remove old ExternalRef

ALTER TABLE IF EXISTS external_ref
  DROP CONSTRAINT IF EXISTS FK_4g2i2qry4941xmqijgeo8ns2h;

ALTER TABLE IF EXISTS external_ref
  DROP CONSTRAINT IF EXISTS FK_bu7q5itmt7w7q1bex049xvac7;

ALTER TABLE IF EXISTS external_ref
  DROP CONSTRAINT IF EXISTS FK_f7igpcpvgcmdfb7v3bgjluqsf;

DROP TABLE IF EXISTS external_ref CASCADE;

GRANT SELECT ON instance_resource_vw TO ${webUserName};
GRANT SELECT ON instance_resource_vw TO read_only;

-- version
UPDATE db_version
SET version = 22
WHERE id = 1;

