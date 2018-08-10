drop function if exists synonym_as_html( bigint );
create function synonym_as_html(instanceid bigint)
  returns TABLE(html text)
language sql
as $$
SELECT CASE
         WHEN it.nomenclatural
                 THEN '<nom>' || synonym.full_name_html || ' <type>' || it.name || '</type></nom>'
         WHEN it.taxonomic
                 THEN '<tax>' || synonym.full_name_html || ' <type>' || it.name || '</type></tax>'
         WHEN it.misapplied
                 THEN '<mis>' || synonym.full_name_html || ' <type>' || it.name || '</type> by <citation>' ||
                      cites_ref.citation_html
                        ||
                      '</citation></mis>'
         WHEN it.synonym
                 THEN '<syn>' || synonym.full_name_html || ' <type>' || it.name || '</type></syn>'
         ELSE ''
           END
FROM Instance i,
     Instance syn_inst
       JOIN instance_type it ON syn_inst.instance_type_id = it.id
       JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
       JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
    ,
     NAME synonym
WHERE syn_inst.cited_by_id = i.id
  AND i.id = instanceid
  AND synonym.id = syn_inst.name_id
ORDER BY it.nomenclatural DESC, it.taxonomic DESC, it.misapplied DESC, synonym.simple_name, cites_ref.year ASC,
         cites_inst.id ASC, synonym.id ASC;
$$;

DROP FUNCTION IF EXISTS synonyms_as_html( BIGINT );
CREATE FUNCTION synonyms_as_html(instance_id BIGINT)
  RETURNS TEXT
LANGUAGE SQL
AS $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_as_html(instance_id) AS html;
$$;

DROP FUNCTION IF EXISTS synonyms_as_jsonb( BIGINT, TEXT );
CREATE FUNCTION synonyms_as_jsonb(instance_id BIGINT, host TEXT)
  RETURNS JSONB
LANGUAGE SQL
AS $$
SELECT jsonb_build_object('list',
                          coalesce(
                            jsonb_agg(jsonb_build_object(
                                        'host', host,
                                        'instance_id', syn_inst.id,
                                        'instance_link',
                                        '/instance/apni/' || syn_inst.id,
                                        'concept_link',
                                        '/instance/apni/' || cites_inst.id,
                                        'simple_name', synonym.simple_name,
                                        'type', it.name,
                                        'name_id', synonym.id :: BIGINT,
                                        'name_link',
                                        '/name/apni/' || synonym.id,
                                        'full_name_html', synonym.full_name_html,
                                        'nom', it.nomenclatural,
                                        'tax', it.taxonomic,
                                        'mis', it.misapplied,
                                        'cites', cites_ref.citation_html,
                                        'cites_link',
                                        '/reference/apni/' || cites_ref.id,
                                        'year', cites_ref.year
                                          )), '[]' :: JSONB)
           )
FROM Instance i,
     Instance syn_inst
       JOIN instance_type it ON syn_inst.instance_type_id = it.id
       JOIN instance cites_inst ON syn_inst.cites_id = cites_inst.id
       JOIN reference cites_ref ON cites_inst.reference_id = cites_ref.id
    ,
     name synonym
WHERE i.id = instance_id
  AND syn_inst.cited_by_id = i.id
  AND synonym.id = syn_inst.name_id;
$$;
