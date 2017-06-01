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

CREATE OR REPLACE FUNCTION find_name_in_tree(pname name.id%TYPE, ptree tree_arrangement.id%TYPE) RETURNS tree_link.id%TYPE AS $$
DECLARE
  -- declarations
  ct integer;
  base_id tree_arrangement.id%TYPE;
  link_id tree_link.id%TYPE;
BEGIN
  -- if this is a simple tree, then we can just look for the tree link directly.
  -- if it is a tree based on another tree, then we must do a treewalk

  select base_arrangement_id into base_id from tree_arrangement a where a.id = ptree;

  begin
    IF base_id is null then
      -- ok. look for the name as a current node in the tree, and find the link to its current parent.

      select l.id INTO STRICT link_id
      from tree_node c
        join tree_link l on c.id = l.subnode_id
        join tree_node p on l.supernode_id = p.id
      where c.name_id = pname
            and c.tree_arrangement_id = ptree
            and c.next_node_id is null
            and p.tree_arrangement_id = ptree
            and p.next_node_id is null;
    ELSE
      -- ok. we need to do a treewalk. As always, this gets nasty.

      with RECURSIVE walk as (
        select l.id as stem_link, l.id as leaf_link, p.tree_arrangement_id = ptree as foundit
        from tree_node c
          join tree_link l on c.id = l.subnode_id
          join tree_node p on l.supernode_id = p.id
        where
          c.name_id = pname
          and (c.tree_arrangement_id = ptree or c.tree_arrangement_id = base_id)
          and c.next_node_id is null
          and (p.tree_arrangement_id = ptree or p.tree_arrangement_id = base_id)
          and p.next_node_id is null
        UNION ALL
        SELECT
          superlink.id as stem_link, walk.leaf_link, p.tree_arrangement_id = ptree as foundit
        FROM walk
          JOIN tree_link sublink on walk.stem_link = sublink.id
          join tree_link superlink on sublink.supernode_id = superlink.subnode_id
          join tree_node p on superlink.supernode_id = p.id
        where not walk.foundit -- clip the search
              and (p.tree_arrangement_id = ptree or p.tree_arrangement_id = base_id)
              and p.next_node_id is null
      )
      select leaf_link INTO STRICT link_id from walk where foundit;

    END IF;

    return link_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise notice 'no data found';
      return null;
    WHEN TOO_MANY_ROWS THEN
      raise notice 'too many rows';
      RAISE 'Multiple placements of name % in tree %', pname, ptree USING ERRCODE = 'unique_violation';
  end;
END;
$$ LANGUAGE plpgsql;

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
