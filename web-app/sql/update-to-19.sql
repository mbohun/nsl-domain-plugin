DROP TABLE IF EXISTS shard_config;

CREATE TABLE shard_config (
  id    INT8 DEFAULT nextval('hibernate_sequence') NOT NULL,
  name  VARCHAR(255)                               NOT NULL,
  value VARCHAR(5000)                              NOT NULL,
  PRIMARY KEY (id)
);
-- add back the defaults, which will need to be configured per shard
INSERT INTO public.shard_config (id, name, value) VALUES
  (nextval('hibernate_sequence'), 'config rules', 'All lower case names, space separated, follow the pattern hierachy');
INSERT INTO public.shard_config (id, name, value) VALUES (nextval('hibernate_sequence'), 'name space', 'APNI');
INSERT INTO public.shard_config (id, name, value) VALUES (nextval('hibernate_sequence'), 'name tree label', 'APNI');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'classification tree label', 'APC');

-- add default descriptions
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'APNI description',
        'The Australian Plant Name Index (APNI) is a tool for the botanical community that deals with plant names and their usage in the scientific literature, whether as a current name or synonym. APNI does not recommend any particular taxonomy or nomenclature. For a listing of currently accepted scientific names for the Australian vascular flora, please use the Australian Plant Census (APC) link above.');

INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'APC description',
        'The Australian Plant Census (APC) is a list of the accepted scientific names for the Australian vascular flora, ferns, gymnosperms, hornworts and liverworts, both native and introduced, and includes synonyms and misapplications for these names. The APC covers all published scientific plant names used in an Australian context in the taxonomic literature, but excludes taxa known only from cultivation in Australia. The taxonomy and nomenclature adopted for the APC are endorsed by the Council of Heads of Australasian Herbaria (CHAH).');

CREATE OR REPLACE FUNCTION is_instance_in_tree(pinstance instance.id%TYPE, ptree tree_arrangement.id%TYPE) RETURNS boolean AS $$
DECLARE
  -- declarations
  ct integer;
  base_id tree_arrangement.id%TYPE;
BEGIN
  -- OK. Is this instance directly in the tree as a current node?

  select count(*) into ct
  from tree_node n
  where n.instance_id = pinstance
        and n.tree_arrangement_id = ptree
        and n.next_node_id is null;

  if ct <> 0 then
    return true;
  end if;

  -- is the tree derived from some other tree?

  select base_arrangement_id into base_id from tree_arrangement a where a.id = ptree;

  if base_id is null then
    return false;
  end if;

  -- right. This tree is derived from another tree. That means that the instance might be in that
  -- other tree and adopted to this one. here's where we need to do a treewalk.
  -- this code assumes that the tree will have at least one node belonging to it at the root, which currently
  -- is the case.

  with recursive treewalk as (
    select n.id as node_id, n.tree_arrangement_id
    from tree_node n
    where n.instance_id = pinstance
          and n.tree_arrangement_id = base_id
          and n.next_node_id is null
    union all
    select n.id as node_id, n.tree_arrangement_id
    from treewalk
      join tree_link l on treewalk.node_id = l.subnode_id
      join tree_node n on l.supernode_id = n.id
    where treewalk.tree_arrangement_id <> ptree -- clip search here
          and n.next_node_id is null
          and n.tree_arrangement_id in (ptree, base_id)
  )
  select count(node_id) into ct from treewalk where treewalk.tree_arrangement_id = ptree;

  return ct <> 0;
END;
$$ LANGUAGE plpgsql;


-- version
UPDATE db_version
SET version = 19
WHERE id = 1;
