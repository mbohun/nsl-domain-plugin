-- 
-- This script sets up the base data for the boatree app. This includes the 'end' tree, out in-house namespaces, and the empty nsl/apc/afd trees
--

delete from tree_link;
update tree_arrangement set node_id = null;
delete from tree_node;
delete from tree_arrangement;
delete from tree_event;
delete from tree_uri_ns;


-- THESE IDS ARE SYSTEM-WIDE CONSTANTS. THEY MAY APPEAR AS MAGIC NUMBERS IN CODE.
-- LABELS ARE ALSO MAGIC NUMBERS, USUALLY FETCHED BY THE tree_get_ns_id() FUNCTION.
-- It's 12:03 AM, and the labels I pick right now are what we are stuck with forever. I'll make 'em short.

-- I use ID zero because the 'no namespace' namespace is a null object. Its purpose is so that we don't have to outer join
-- every time we write a query that (for instance) constructs the taxon_uri for a node
-- we include this explicitly so that we dont have to outer join all over the shop.

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	0, 1,
	'', 
	'none', 'no namespace',
	'No namespace - the ID contains the full URI.',
	0, null,
	null, null
);

-- we include this exoplicitly so that the null tree and node URI reliably have ids (1,0)
insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	1, 1,
	'http://biodiversity.org.au/voc/boatree/BOATREE#', 
	'boatree-voc',
	'BOATREE',
	'Top level BOATREE vocabulary.',
	0, 'http://biodiversity.org.au/voc/boatree/BOATREE',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/boatree/voc/', 
	'voc', 'voc namespace',
	'Namespace of the vocabularies served by this instance.',
	0, null,
	null, null
);

update tree_uri_ns
set owner_uri_ns_part_id = (select id from tree_uri_ns where label = 'voc'),
	owner_uri_id_part = 'voc'
where label = 'voc';

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/boatree/voc/ns#', 
	'ns', 'uri_ns namespace',
	'Namespace of the uri namespaces.',
	(select id from tree_uri_ns where label = 'voc'), 'ns',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/boatree/classification/', 
	'clsf', 'classification namespace',
	'Namespace for top-level public trees, by text identifier.',
	(select id from tree_uri_ns where label = 'voc'), 'classification',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/boatree/arrangement/', 
	'arr', 'arrangement namespace',
	'Namespace for all arrangemnts, by physical id.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/boatree/node/', 
	'node', 'arrangement node namespace',
	'Namespace for arrangement nodes.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://www.w3.org/2001/XMLSchema#', 
	'xs', 'XML Schema',
	'Base datatypes.',
	0, 'http://www.w3.org/1999/02/22-rdf-syntax-ns',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 
	'rdf', 'rdf namespace',
	'Namespace for rdf.',
	0, 'http://www.w3.org/1999/02/22-rdf-syntax-ns',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://www.w3.org/2000/01/rdf-schema#', 
	'rdfs', 'rdf schema namespace',
	'Namespace for rdf schema.',
	0, 'http://www.w3.org/2000/01/rdf-schema',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://purl.org/dc/elements/1.1/', 
	'dc', 'dublin core',
	'Namespace for Dublin Core.',
	0, 'http://purl.org/dc/elements/1.1',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://purl.org/dc/terms/', 
	'dcterms', 'dublin core terms',
	'Namespace for Dublin Core terms.',
	0, 'http://purl.org/dc/terms',
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://www.w3.org/2002/07/owl#', 
	'owl', 'Web Ontology Language',
	'Namespace for Web Ontology Language (OWL).',
	0, 'http://www.w3.org/2002/07/owl',
	null, null
);

-- not sure about these. Is Greg's stuff keeping the apni ids? Do we need a new namespace for
-- APC names/taxa?

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/apni.name/', 
	'apni-name', 'APNI name', 
	'An APNI name.',
	0, null,
	1, 'PLANT_NAME'
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/apni.taxon/', 
	'apni-taxon', 'APNI taxon',
	'An APNI taxon.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/afd.name/', 
	'afd-name', 'AFD name', 
	'An AFD name.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/afd.taxon/', 
	'afd-taxon', 'AFD taxon',
	'An AFD taxon.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/nsl.name/', 
	'nsl-name', 'NSL name',
	'An NSL name.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/nsl.instance/', 
	'nsl-instance', 'NSL instance',
	'An NSL instance.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/voc/apc/APC#', 
	'apc-voc', 'APC vocabulary',
	'Vocabulary terms relating specifically to the APC tree.',
	0, null,
	null, null
);

insert into tree_uri_ns(id,lock_version,uri,label,title,description,owner_uri_ns_part_id,owner_uri_id_part,id_mapper_namespace_id,id_mapper_system) values (
	nextval('nsl_global_seq'), 1, 
	'http://biodiversity.org.au/voc/apc/concept/', 
	'apc-concept', 'APC placement',
	'APC_CONCEPT.APC_ID from APNI.',
	0, null,
	null, null
);

-- create the end node. global across all graphs that make use of this structure and ontology
-- the physical id of the end tree and the node are both zero.
-- THIS IS A  MAGIC NUMBER AND MAY APPEAR IN CODE.

-- the end node is a null object. It means "this node has been replaced and is no longer current, but is has not been replaced by anything".
-- If I did not have an end node, then I would have to keep a "status" field on the node table - I'd be spreading the info over two fields, two
-- rdf and json properties, and creating a situation where inconsistent data becomes possible.

insert into tree_arrangement(id, lock_version, tree_type, is_synthetic, label, description) 
values (0, 1, 'E', 'N', 'END-TREE', 'The END tree. This tree is the same abstract object across all instances of this data structure.');

insert into tree_node(id, internal_type, lock_version, is_synthetic, tree_arrangement_id, type_uri_ns_part_id, type_uri_id_part) 
values (0, 'S', 1, 'N', 0, 1, 'EndNode');

update tree_arrangement set node_id = 0;

-- create TMP tree (used for testing, dev)

insert into tree_arrangement(id, lock_version, tree_type, is_synthetic, label, description)
values (nextval('nsl_global_seq'), 1, 'P', 'N', 'TMP','Temp classification for testing forms');

insert into tree_node(id, internal_type, lock_version, is_synthetic, tree_arrangement_id, type_uri_ns_part_id, type_uri_id_part) 
values (
	nextval('nsl_global_seq'), 'S', 1, 'N',
	(select id from tree_arrangement where tree_type = 'P' and label = 'TMP'),
	(select id from tree_uri_ns where label='boatree-voc'), 'classification-node'
);

update tree_arrangement set node_id = currval('nsl_global_seq') 
where tree_type = 'P' and label = 'TMP';

insert into tree_node(id, internal_type, lock_version, is_synthetic, tree_arrangement_id, type_uri_ns_part_id, type_uri_id_part) 
values (
	nextval('nsl_global_seq'), 'T', 1, 'N',
	(select id from tree_arrangement where tree_type = 'P' and label = 'TMP'),
	(select id from tree_uri_ns where label='boatree-voc'), 'classification-root'
);

-- link all classification root nodes to the classifictaion node nodes. Note that the classifications created above (AFD, NSL, APC, TMP)
-- are not complete until this step is done.

insert into tree_link(id, lock_version, is_synthetic, supernode_id, subnode_id,  type_uri_ns_part_id, type_uri_id_part, versioning_method, link_seq)
select
	nextval('nsl_global_seq'), 1, 'N',
	t.node_id, r_node.id,
	(select id from tree_uri_ns where label='boatree-voc'), 'classification-root-link',
	'T', 1
from tree_arrangement t, tree_node r_node
where
t.id = r_node.tree_arrangement_id
and r_node.type_uri_id_part = 'classification-root';

-- finally, create a tree event for this current load and set it as the event for the various setup operations
-- that we have just done
-- I will use 'NSL-SCHEMA' as the username for now

-- zero event for the creation of the end node and tree

insert into tree_event (id, lock_version, time_stamp, auth_user, note)
values (0, 1, now(), 'NSL SCHEMA', 'Event zero - construction of end node');

update tree_node set checked_in_at_id = 0 where id = 0;

-- event for the creation of the site-specific AFD, APC, NSL and TMP trees

insert into tree_event (id, lock_version, time_stamp, auth_user, note)
values (nextval('nsl_global_seq'), 1, now(), 'NSL SCHEMA', 'Initial trees');

update tree_node set checked_in_at_id = currval('nsl_global_seq') where id <> 0;


-- I am assuming that we are using the APNI shard.

update tree_event set namespace_id = (select id from namespace where name = 'APNI') where id <> 0;

update tree_arrangement set namespace_id = (select id from namespace where name = 'APNI') where id <> 0;

commit;
