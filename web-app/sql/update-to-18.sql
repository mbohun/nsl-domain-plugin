ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

ALTER TABLE tree_arrangement
  ADD COLUMN shared BOOLEAN DEFAULT TRUE;

DROP TRIGGER IF EXISTS reference_update
ON author;

CREATE TRIGGER reference_update
AFTER INSERT OR UPDATE OR DELETE ON reference
FOR EACH ROW
EXECUTE PROCEDURE reference_notification();

Update namespace set name = 'Algae' where name = 'AusAlgae';
Update namespace set description_html = '(description of <b>Algae</b>)' where name = 'Algae';
Update namespace set rdf_id = 'algae' where name = 'Algae';

INSERT INTO namespace (id, lock_version, name, description_html, rdf_id) VALUES (nextval('nsl_global_seq'), 0, 'Lichen', '(description of <b>Lichen</b>)', 'lichen');
INSERT INTO public.namespace (id, lock_version, name, description_html, rdf_id) VALUES (nextval('nsl_global_seq'), 0, 'Fungi', '(description of <b>Fungi</b>)', 'fungi');


create index idx_node_current_name_a on tree_node(name_id, tree_arrangement_id) where replaced_at_id is null;

 create index idx_node_current_name_b on tree_node(name_id, tree_arrangement_id) where next_node_id is null; 

create index idx_node_current_instance_a on tree_node(instance_id, tree_arrangement_id) where replaced_at_id is null; 

create index idx_node_current_instance_b on tree_node(instance_id, tree_arrangement_id) where next_node_id is null; 




-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
