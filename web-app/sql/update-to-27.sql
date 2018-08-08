-- functions to get ordered output as needed by the APNI format
-- get basionym information for a name

drop function if exists apni_basionym(bigint);
create function apni_basionym(nameid bigint)
  returns table(instance_id   bigint,
                instance_type text,
                full_name     text,
                name_status   text,
                sort_name     text)
language sql
as $$
select bas_inst.id, bas_it.name, basionym.full_name, bas_status.name, basionym.sort_name
from instance primary_inst
       left join instance bas_inst on bas_inst.cited_by_id = primary_inst.id
       join name basionym on bas_inst.name_id = basionym.id
       join name_status bas_status on bas_status.id = basionym.name_status_id
       join instance_type bas_it
         on bas_inst.instance_type_id = bas_it.id and bas_it.nomenclatural and bas_it.name = 'basionym'
       join instance_type primary_it on primary_inst.instance_type_id = primary_it.id and primary_it.primary_instance
where primary_inst.name_id = nameid;
$$;

-- get the basionym sort name for a name or null

drop function if exists apni_basionym_sort_name(bigint);
create function apni_basionym_sort_name(nameid bigint)
  returns text
language sql
as $$
select basionym.sort_name
from name subject
       join instance primary_inst on primary_inst.name_id = subject.id
       join instance_type primary_it on primary_inst.instance_type_id = primary_it.id and primary_it.primary_instance
       join instance bas_inst on bas_inst.cited_by_id = primary_inst.id
       join instance_type it on bas_inst.instance_type_id = it.id and it.nomenclatural and it.name = 'basionym'
       join name basionym on bas_inst.name_id = basionym.id
where subject.id = nameid
  and subject.base_author_id is not null
$$;

-- get the synonyms of this instance in apni output (flora) order

drop function if exists apni_ordered_synonymy(bigint);

create function apni_ordered_synonymy(instanceid bigint)
  returns TABLE(instance_id      bigint,
                instance_type    text,
                instance_type_id bigint,
                name_id          bigint,
                full_name        text,
                full_name_html   text,
                name_status      text,
                citation         text,
                citation_html    text,
                year             int,
                page             text,
                sort_name        text,
                misapplied       boolean,
                tax_nov          boolean,
                basionym_sort         text)
language sql
as $$
select i.id,
       it.has_label             as instance_type,
       it.id                    as instance_type_id,
       n.id                     as name_id,
       n.full_name,
       n.full_name_html,
       ns.name                  as name_status,
       r.citation,
       r.citation_html,
       r.year,
       cites.page,
       n.sort_name,
       it.misapplied,
       n.base_author_id is null as tax_nov,
       case
         when n.base_author_id is not null then apni_basionym_sort_name(n.id)
         else n.sort_name end   as basionym_sort
from instance i
       join instance_type it on i.instance_type_id = it.id
       join name n on i.name_id = n.id
       left outer join name_status ns on n.name_status_id = ns.id
       join instance cites on i.cites_id = cites.id
       join reference r on cites.reference_id = r.id
where i.cited_by_id = instanceid
order by (it.sort_order < 20) desc, it.nomenclatural desc, it.taxonomic desc, basionym_sort, tax_nov desc, n.sort_name,
         it.pro_parte, it.misapplied desc, it.doubtful, r.year, cites.page, cites.id;
$$;

-- apni ordered synonymy as a text output

drop function if exists apni_ordered_synonymy_text(bigint);
create function apni_ordered_synonymy_text(instanceid bigint)
  returns text
language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                     when syn.name_status = 'legitimate' then ''
                     else ' ' || syn.name_status end) ||
                  (case
                     when syn.misapplied then syn.citation
                     else '' end), E'\n')
from apni_ordered_synonymy(instanceid) syn;
$$;
​
-- if this is a relationship instance what are we a synonym of
​
drop function if exists apni_synonym(bigint);
create function apni_synonym(instanceid bigint)
  returns TABLE(instance_id    bigint,
                instance_type  text,
                name_id        bigint,
                full_name      text,
                full_name_html text,
                name_status    text,
                citation       text,
                citation_html  text,
                year           int,
                page           text,
                misapplied     boolean,
                sort_name      text)
language sql
as $$
select i.id,
       it.of_label as instance_type,
       n.id        as name_id,
       n.full_name,
       n.full_name_html,
       ns.name,
       r.citation,
       r.citation_html,
       r.year,
       i.page,
       it.misapplied,
       n.sort_name
from instance i
       join instance_type it on i.instance_type_id = it.id
       join name n on i.name_id = n.id
       join name_status ns on n.name_status_id = ns.id
       join reference r on i.reference_id = r.id
where i.id = instanceid
  and it.relationship;
$$;
​
-- if this is a relationship instance what are we a synonym of as text

drop function if exists apni_synonym_text(bigint);
create function apni_synonym_text(instanceid bigint)
  returns text
language sql
as $$
select string_agg('  ' ||
                  syn.instance_type ||
                  ': ' ||
                  syn.full_name ||
                  (case
                     when syn.name_status = 'legitimate' then ''
                     else ' ' || syn.name_status end) ||
                  (case
                     when syn.misapplied
                             then 'by ' || syn.citation
                     else '' end), E'\n')
from apni_synonym(instanceid) syn;
$$;
​
-- apni ordered references for a name
​
drop function if exists apni_ordered_refrences(bigint);
create function apni_ordered_refrences(nameid bigint)
  returns TABLE(instance_id   bigint,
                instance_type text,
                citation      text,
                citation_html text,
                year          int,
                pages         text,
                page          text)
language sql
as $$
select i.id, it.name, r.citation, r.citation_html, r.year, r.pages, coalesce(i.page, citedby.page, '-')
from instance i
       join reference r on i.reference_id = r.id
       join instance_type it on i.instance_type_id = it.id
       left outer join instance citedby on i.cited_by_id = citedby.id
where i.name_id = nameid
group by r.id, i.id, it.id, citedby.id
order by r.year, it.protologue, it.primary_instance, r.citation, r.pages, i.page, r.id;
$$;

-- get the synonyms of an instance as html to store in the tree in apni synonymy order

drop function if exists synonym_as_html(bigint);
create function synonym_as_html(instanceid bigint)
  returns TABLE(html text)
language sql
as $$
SELECT CASE
         WHEN it.nomenclatural
                 THEN '<nom>' || full_name_html || ' <type>' || it.name || '</type></nom>'
         WHEN it.taxonomic
                 THEN '<tax>' || full_name_html || ' <type>' || it.name || '</type></tax>'
         WHEN it.misapplied
                 THEN '<mis>' || full_name_html || ' <type>' || it.name || '</type> by <citation>' ||
                      citation_html
                        ||
                      '</citation></mis>'
         WHEN it.synonym
                 THEN '<syn>' || full_name_html || ' <type>' || it.name || '</type></syn>'
         ELSE ''
           END
FROM apni_ordered_synonymy(instanceid)
       join instance_type it on instance_type_id = it.id
$$;

-- build JSONB representation of synonyms inside a shard
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

-- re-write the synonymy html based on the synonymy at the time

drop function if exists synonym_current_as_html(bigint);

create function synonym_current_as_html(elementid bigint)
  returns TABLE(html text)
language sql
as $$
SELECT CASE
         WHEN it.nomenclatural
                 THEN '<nom>' || full_name_html || ' <type>' || it.name || '</type></nom>'
         WHEN it.taxonomic
                 THEN '<tax>' || full_name_html || ' <type>' || it.name || '</type></tax>'
         WHEN it.misapplied
                 THEN '<mis>' || full_name_html || ' <type>' || it.name || '</type> by <citation>' ||
                      citation_html
                        ||
                      '</citation></mis>'
         WHEN it.synonym
                 THEN '<syn>' || full_name_html || ' <type>' || it.name || '</type></syn>'
         ELSE ''
           END
from tree_element te,
     apni_ordered_synonymy(te.instance_id) ord_syn
       join instance_type it on ord_syn.instance_type_id = it.id
where te.id = elementid
    and ord_syn.instance_id in (select ((tax_syn1 ->> 'instance_id') :: numeric :: bigint)
                      FROM jsonb_array_elements(te.synonyms -> 'list') AS tax_syn1);
$$;

drop function if exists current_synonyms_as_html(bigint);

create function current_synonyms_as_html(elementid bigint)
  returns text
language sql
as $$
SELECT '<synonyms>' || string_agg(html, '') || '</synonyms>'
FROM synonym_current_as_html(elementid) AS html;
$$;

update tree_element te
set synonyms_html = coalesce(current_synonyms_as_html(te.id), '<synonyms></synonyms>')
from tree_version_element tve join tree on tve.tree_version_id = tree.current_tree_version_id
where tve.tree_element_id = te.id
;

update tree_element te
set synonyms_html = coalesce(current_synonyms_as_html(te.id), '<synonyms></synonyms>')
from tree_version_element tve join tree on tve.tree_version_id = tree.default_draft_tree_version_id
where tve.tree_element_id = te.id
;

drop function if exists synonym_current_as_html(bigint);
drop function if exists current_synonyms_as_html(bigint);

-- version
UPDATE db_version
SET version = 27
WHERE id = 1;

