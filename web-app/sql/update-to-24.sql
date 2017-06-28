-- new tree structure
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
  DROP CONSTRAINT IF EXISTS FK_tb2tweovvy36a4bgym73jhbbk;

-- 8< ---
ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_slpx4w0673tudgw4fcodauilv;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_89rcrnlb8ed10mgp22d3cj646;
-- 8< ---

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_964uyddp8ju1ya5v2px9wx5tf;

ALTER TABLE IF EXISTS tree_element
  DROP CONSTRAINT IF EXISTS FK_kaotdsllnfojld6pdxb8c9gml;

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
  tree_version_id     INT8                              NOT NULL,
  tree_element_id     INT8                              NOT NULL,
  lock_version        INT8 DEFAULT 0                    NOT NULL,
  display_string      TEXT                              NOT NULL,
  element_link        TEXT                              NOT NULL,
  excluded            BOOLEAN DEFAULT FALSE             NOT NULL,
  instance_id         INT8                              NOT NULL,
  instance_link       TEXT                              NOT NULL,
  name_id             INT8                              NOT NULL,
  name_link           TEXT                              NOT NULL,
  name_path           TEXT                              NOT NULL,
  names               TEXT DEFAULT ''                   NOT NULL,
  parent_Version_Id   INT8,
  parent_Element_Id   INT8,
  previous_Version_Id INT8,
  previous_Element_Id INT8,
  profile             JSONB,
  rank_path           JSONB,
  simple_name         TEXT                              NOT NULL,
  source_shard        TEXT DEFAULT ''                   NOT NULL,
  tree_path           TEXT                              NOT NULL,
  updated_at          TIMESTAMP WITH TIME ZONE          NOT NULL,
  updated_by          VARCHAR(255)                      NOT NULL,
  PRIMARY KEY (tree_version_id, tree_element_id)
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
  ADD CONSTRAINT FK_tb2tweovvy36a4bgym73jhbbk
FOREIGN KEY (tree_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_element
  ADD CONSTRAINT FK_964uyddp8ju1ya5v2px9wx5tf
FOREIGN KEY (parent_Version_Id, parent_Element_Id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_element
  ADD CONSTRAINT FK_kaotdsllnfojld6pdxb8c9gml
FOREIGN KEY (previous_Version_Id, previous_Element_Id)
REFERENCES tree_element;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_tiniptsqbb5fgygt1idm1isfy
FOREIGN KEY (previous_version_id)
REFERENCES tree_version;

ALTER TABLE IF EXISTS tree_version
  ADD CONSTRAINT FK_4q3huja5dv8t9xyvt5rg83a35
FOREIGN KEY (tree_id)
REFERENCES tree;

CREATE INDEX tree_name_path_Index
  ON tree_element (name_path);

CREATE INDEX tree_simple_name_Index
  ON tree_element (simple_name);

CREATE INDEX name_name_path_Index
  ON name (name_path);

ALTER TABLE IF EXISTS name
  ADD CONSTRAINT FK_whce6pgnqjtxgt67xy2lfo34
FOREIGN KEY (family_id)
REFERENCES name;

CREATE INDEX name_path_gin_trgm
  ON tree_element USING GIN (name_path gin_trgm_ops);
CREATE INDEX names_gin_trgm
  ON tree_element USING GIN (names gin_trgm_ops);

-- version
UPDATE db_version
SET version = 24
WHERE id = 1;

