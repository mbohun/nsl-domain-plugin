
-- psql -f rebuild_ozmoss_apc_tree.sql ozmoss pg

CREATE OR REPLACE FUNCTION rebuild_ozmoss_apc_tree()
  RETURNS integer AS
$BODY$
-- query from Nils is

--SELECT n.id, n.full_name, n.parent_id, r.id AS reference_id, r.citation, it.name AS instance_type, inote.value AS distribution
--FROM name n
--JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
--JOIN instance_type it ON i.instance_type_id=it.id
--JOIN reference r ON i.reference_id=r.id
--LEFT JOIN instance_note inote ON i.id=inote.instance_id AND inote.instance_note_key_id=10000003
--WHERE n.name_status_id=54360;

-- dont need instance note or the reference to build the tree, so this reduces to

--SELECT n.id as name_id, i.id as instance_id, n.parent_id as parent_name_id, it.name AS instance_type
--FROM name n
--JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
--JOIN instance_type it ON i.instance_type_id=it.id
--WHERE n.name_status_id=54360;

-- this build only supports instance type 'excluded' vs anything else. Ideally, the instance type would become
-- the node type because all of these instances are ozmoss instances. Our tree gear won't support this at present.
-- that is: the underlying data will, but the editor and display only understand apc attributes. What ought to happen is
-- that we have an ozmoss tree vocabulary for these things

DECLARE
  mApcVoc integer;
  mNslNameVoc integer;
  mNslInstanceVoc integer;
  mOzmossNs integer;
  mApcTree integer;
  mApcNode integer;
  mCurrentRootNode integer;
  mEvent integer;
  mRootNode integer;
  nn integer;
BEGIN
  raise info 'rebuild_ozmoss_apc_tree';
  select id into mNslNameVoc from tree_uri_ns where label = 'nsl-name';
  raise info 'mNslNameVoc is %', mNslNameVoc;
  select id into mNslInstanceVoc from tree_uri_ns where label = 'nsl-instance';
  raise info 'mNslInstanceVoc is %', mNslInstanceVoc;
  select id into mApcVoc from tree_uri_ns where label = 'apc-voc';
  raise info 'APC vocabulary is %', mApcVoc;
  select id into mOzmossNs from namespace where name = 'AusMoss';
  raise info 'AusMoss namespace is %', mOzmossNs;
  select id from tree_arrangement into mApcTree where namespace_id = mOzmossNs and tree_type = 'P' and label = 'APC';
  raise info 'APC tree is %', mApcTree;
  select node_id from tree_arrangement into mApcNode where id = mApcTree;
  raise info 'APC top node is %', mApcNode;
  select subnode_id from tree_link into mCurrentRootNode where supernode_id = mApcNode;
  raise info 'APC current root is %', mCurrentRootNode;
  select nextval('nsl_global_seq') into mEvent;
  raise info 'Event for this operation will be %', mEvent;
  select nextval('nsl_global_seq') into mRootNode;
  raise info 'New root node will be %', mRootNode;

  insert into tree_event(id, namespace_id, lock_version, auth_user, note, time_stamp)
  values(mEvent, mOzmossNs, 1, 'nsl', 'rebuild ozmoss apc tree', current_timestamp);

  insert into tree_node(
    id, lock_version, checked_in_at_id, prev_node_id,
    internal_type, tree_arrangement_id, is_synthetic,
    type_uri_ns_part_id, type_uri_id_part
  )
  values (
    mRootNode, 1, mEvent, mCurrentRootNode,
    'T', mApcTree, 'Y',
    1, 'classification-root'
  );

  select count(*) into nn
  from tree_node
  where tree_arrangement_id = mApcTree
  and internal_type <> 'V'
  and id <> mApcNode
  and tree_arrangement_id is null;

  raise info 'end-dating % nodes', nn;

  update tree_node
    set next_node_id = 0, replaced_at_id = mEvent
    where tree_arrangement_id = mApcTree
    and internal_type <> 'V'
    and id <> mApcNode
    and tree_arrangement_id is null;

  raise debug 'building new empty tree';

  update tree_node set next_node_id = mRootNode where id = mCurrentRootNode;
  update tree_link set subnode_id = mRootNode where supernode_id = mApcNode;

  SELECT count(*) into nn
  FROM name n
  JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
  JOIN instance_type it ON i.instance_type_id=it.id
  WHERE n.name_status_id=54360 and it.standalone;

  raise info 'creating % new nodes', nn;

  insert into tree_node (
    id, lock_version, checked_in_at_id, internal_type, is_synthetic,
    tree_arrangement_id,
    type_uri_ns_part_id, type_uri_id_part,
    name_id, name_uri_ns_part_id, name_uri_id_part,
    instance_id, taxon_uri_ns_part_id, taxon_uri_id_part)
  SELECT
    nextval('nsl_global_seq'), 1, mEvent, 'T', 'Y',
    mApcTree,
    mApcVoc, case
             when  it.name ='excluded name' or  it.name ='occurrence doubtful' or  it.name ='status uncertain'
               then 'ApcExcluded' else 'ApcConcept' end,
    n.id, mNslNameVoc, n.id,
    i.id, mNslInstanceVoc, i.id
  FROM name n
    JOIN instance i ON n.id=i.name_id AND i.reference_id=10018098
    JOIN instance_type it ON i.instance_type_id=it.id
  WHERE n.name_status_id=54360  and it.standalone;

  insert into tree_link(
    id, lock_version, link_seq,
    subnode_id, supernode_id, is_synthetic,
    type_uri_id_part, type_uri_ns_part_id,
    versioning_method)
  select
    nextval('nsl_global_seq'), 1, name_id, -- use name id as link seq, will magically make link history work
    id, mRootNode, 'Y',
    null, 0,
    'V'
  from tree_node
  where checked_in_at_id = mEvent
  and id <> mRootNode;

  raise debug 'relinking the names';

  update tree_link
    set supernode_id =
    coalesce(
    (
      select supnode.id
      from tree_node subnode
      join name on subnode.name_id = name.id
      join tree_node supnode on supnode.name_id = name.parent_id and supnode.tree_arrangement_id = mApcTree and supnode.checked_in_at_id = mEvent
      where subnode.id = tree_link.subnode_id
    ) , mRootNode)
    where supernode_id = mRootNode;

  update tree_node
    set prev_node_id = (select id from tree_node n2 where tree_node.name_id = n2.name_id and n2.replaced_at_id = mEvent)
      where name_id is not NULL and checked_in_at_id = mEvent;

  update tree_node
  set next_node_id =
  (select id from tree_node n2 where tree_node.name_id = n2.name_id and n2.checked_in_at_id = mEvent)
  where name_id is not NULL and replaced_at_id = mEvent;

  return 0;
END;
$BODY$
LANGUAGE plpgsql;

select rebuild_ozmoss_apc_tree();

commit;
