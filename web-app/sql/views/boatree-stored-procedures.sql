-- create views for interrogating the tree
-- previously infeasible, the discovery tht we can index null columns in postgres
-- now means that you can join to these queries and they will run in a reasonable amount of time

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
