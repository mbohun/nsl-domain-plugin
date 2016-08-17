ALTER TABLE instance
  ADD CONSTRAINT no_duplicate_synonyms UNIQUE (name_id, reference_id, instance_type_id, page, cites_id, cited_by_id);

ALTER TABLE tree_arrangement
  ADD COLUMN shared BOOLEAN DEFAULT TRUE;

DROP TRIGGER reference_update
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

-- version
UPDATE db_version
SET version = 18
WHERE id = 1;
