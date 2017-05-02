-- NSL-2347 Add external resources
CREATE TABLE site (
  id           INT8 DEFAULT nextval('nsl_global_seq') NOT NULL,
  lock_version INT8 DEFAULT 0                         NOT NULL,
  created_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  created_by   VARCHAR(50)                            NOT NULL,
  description  VARCHAR(255)                           NOT NULL,
  name         VARCHAR(255)                           NOT NULL,
  updated_at   TIMESTAMP WITH TIME ZONE               NOT NULL,
  updated_by   VARCHAR(50)                            NOT NULL,
  url          VARCHAR(255)                           NOT NULL,
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

-- remove old ExternalRef

alter table if exists external_ref
  drop constraint if exists FK_4g2i2qry4941xmqijgeo8ns2h;

alter table if exists external_ref
  drop constraint if exists FK_bu7q5itmt7w7q1bex049xvac7;

alter table if exists external_ref
  drop constraint if exists FK_f7igpcpvgcmdfb7v3bgjluqsf;

drop table if exists external_ref cascade;




-- version
UPDATE db_version
SET version = 22
WHERE id = 1;

