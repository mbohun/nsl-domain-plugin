-- APNI names view
CREATE MATERIALIZED VIEW apninames AS

  SELECT
    /*n.id                                                    AS name_record_id,
    pro.id                                                  AS protologue_record_id,
 */
    'ICNAFP' :: TEXT                                         AS "nomenclaturalCode",
    'APNI' :: TEXT                                           AS "datasetName",
    nt.name                                                  AS "nameType",
    CASE WHEN apc_inst.id IS NULL
      THEN
        (SELECT '[unplaced ' || CASE WHEN i.cited_by_id IS NULL
          THEN 'name'
                                ELSE 'relationship' END || '?]'
         FROM INSTANCE i
           /*JOIN instance_type t ON t.id = i.instance_type_id*/
           JOIN REFERENCE r ON r.id = i.reference_id
         WHERE i.name_id = n.id
         ORDER BY r.year DESC
         LIMIT 1
        ) /*
      '[unplaced]' */
    ELSE
      CASE WHEN apc_inst.id = apcn.instance_id
        THEN
          apcn.type_uri_id_part
      ELSE
        apc_inst_type.name
      END
    END                                                      AS "taxonomicStatus",
    'http://id.biodiversity.org.au/name/apni/' || n.id       AS "scientificNameID",
    n.full_name                                              AS "scientificName",
    CASE WHEN ns.name NOT IN ('legitimate', '[default]')
      THEN ns.name
    ELSE NULL END                                            AS "nomenclaturalStatus",
    n.simple_name                                            AS "canonicalName",
    CASE WHEN nt.autonym
      THEN
        NULL
    ELSE
      regexp_replace(substring(n.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '', 'g')
    END                                                      AS "scientificNameAuthorship",
    'http://creativecommons.org/licenses/by/3.0/' :: TEXT    AS "ccLicense",
    'http://id.biodiversity.org.au/name/apni/' || n.id       AS "ccAttributionIRI",
    /*CASE WHEN apcn.instance_id IS NOT NULL
       THEN
         'http://id.biodiversity.org.au/node/apni/' || apcn.id
     ELSE NULL END                                            AS "apcTaxonID",*/

    CASE WHEN nt.cultivar = TRUE
      THEN n.name_element
    ELSE NULL END                                            AS "cultivarEpithet",
    n.simple_name_html                                       AS "canonicalNameHTML",
    n.full_name_html                                         AS "scientificNameHTML",

    nt.autonym                                               AS "autonym",
    nt.hybrid                                                AS "hybrid",
    nt.cultivar                                              AS "cultivar",
    nt.formula                                               AS "formula",
    nt.scientific                                            AS "scientific",
    ns.nom_inval                                             AS "nomInval",
    ns.nom_illeg                                             AS "nomIlleg",

    pro_ref.citation                                         AS "namePublishedIn",
    pro_ref.year                                             AS "namePublishedInYear",
    /*'http://id.biodiversity.org.au/instance/apni/' || pro.id AS "nameAccordingToID",*/
    pit.name                                                 AS "nameInstanceType",
    bnm.full_name                                            AS "originalNameUsage",
    CASE WHEN bin.id IS NOT NULL
      THEN 'http://id.biodiversity.org.au/instance/apni/' || bin.id
    ELSE
      CASE WHEN pro.id IS NOT NULL
        THEN 'http://id.biodiversity.org.au/instance/apni/' || pro.id
      ELSE NULL END
    END                                                      AS "originalNameUsageID",
    /*apc_comment.value */
    (SELECT string_agg(regexp_replace(VALUE, E'[\\n\\r\\u2028]+', ' ', 'g'), ' ')
     FROM instance_note nt
       JOIN instance_note_key key1
         ON key1.id = nt.instance_note_key_id
            AND key1.name = 'Type'
     WHERE nt.instance_id = apcn.instance_id)                AS "typeCitation",
    /*
    basionym_author.abbrev                                   AS "basionymAuthor",
    ex_basionym_author.abbrev                                AS "exBasionymAuthor",
    combination_author.abbrev                                AS "comibinationAuthor",
    ex_combination_author.abbrev                             AS "exCombinationAuthor",
    sanctioning_work.abbrev                                  AS "sanctioningWork", */

    rank.name                                                AS "taxonRank",
    rank.sort_order                                          AS "taxonRankSortOrder",
    rank.abbrev                                              AS "taxonRankAbbreviation",

    substring(ntp.rank_path FROM 'Regnum:([^>]*)')           AS "kingdom",
    substring(ntp.rank_path FROM 'Classis:([^>]*)')          AS "class",
    substring(ntp.rank_path FROM 'Subclassis:([^>]*)')       AS "subclass",
    substring(ntp.rank_path FROM 'Familia:([^>]*)')          AS "family",
    substring(ntp.rank_path FROM 'Genus:([^>]*)')            AS "genericName",
    substring(ntp.rank_path FROM 'Species:([^>]*)')          AS "specificEpithet",
    substring(ntp.rank_path FROM 'Species:[^>]*>.*:(.*)\\$') AS "infraspecificEpithet",

    n.created_at                                             AS "created",
    n.updated_at                                             AS "modified",

    n.name_element                                           AS "nameElement",

    CASE WHEN firstHybridParent.id IS NOT NULL
      THEN
        firstHybridParent.full_name
    ELSE NULL END                                            AS "firstHybridParentName",

    CASE WHEN firstHybridParent.id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/name/apni/' || firstHybridParent.id
    ELSE NULL END                                            AS "firstHybridParentNameID",

    CASE WHEN secondHybridParent.id IS NOT NULL
      THEN
        secondHybridParent.full_name
    ELSE NULL END                                            AS "secondHybridParentName",

    CASE WHEN secondHybridParent.id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/name/apni/' || secondHybridParent.id
    ELSE NULL END                                            AS "secondHybridParentNameID" /*

  name_path                                               AS path*/

  FROM NAME n
    JOIN name_type nt ON n.name_type_id = nt.id
    JOIN name_status ns ON n.name_status_id = ns.id
    JOIN name_rank rank ON n.name_rank_id = rank.id

    LEFT OUTER JOIN author combination_author ON combination_author.id = n.author_id
    LEFT OUTER JOIN author basionym_author ON n.base_author_id = basionym_author.id
    LEFT OUTER JOIN author ex_basionym_author ON n.ex_base_author_id = ex_basionym_author.id
    LEFT OUTER JOIN author ex_combination_author ON n.ex_author_id = ex_combination_author.id
    LEFT OUTER JOIN author sanctioning_work ON n.sanctioning_author_id = sanctioning_work.id

    LEFT OUTER JOIN INSTANCE pro /* ON pro.name_id = n.id */
    JOIN instance_type pit ON pit.id = pro.instance_type_id AND pit.primary_instance = TRUE
    JOIN REFERENCE pro_ref ON pro.reference_id = pro_ref.id
      ON pro.name_id = n.id

    LEFT OUTER JOIN INSTANCE bin
    JOIN instance_type bit ON bit.id = bin.instance_type_id AND bit.name = 'basionym'
    JOIN NAME bnm ON bnm.id = bin.name_id
      ON bin.id = pro.cites_id

    LEFT OUTER JOIN INSTANCE apc_inst
    JOIN instance_type apc_inst_type ON apc_inst.instance_type_id = apc_inst_type.id
    JOIN REFERENCE apc_ref ON apc_ref.id = apc_inst.reference_id
    JOIN tree_node apcn
    JOIN tree_arrangement tree ON tree.id = apcn.tree_arrangement_id AND tree.label = 'APC'
    JOIN name_tree_path ntp ON ntp.id = apcn.id
      ON (apcn.instance_id = apc_inst.id OR apcn.instance_id = apc_inst.cited_by_id)
         AND apcn.checked_in_at_id IS NOT NULL
         AND apcn.next_node_id IS NULL
         AND apcn.type_uri_id_part != 'DeclaredBt'
      ON apc_inst.name_id = n.id

    /*LEFT OUTER JOIN instance apc_inst
      JOIN instance_type apc_inst_type ON apc_inst.instance_type_id = apc_inst_type.id
      JOIN tree_node apcn ON apcn.instance_id = apc_inst.id
      JOIN tree_arrangement tree
      ON tree.id = apcn.tree_arrangement_id
         AND tree.label = 'APC'
         AND apcn.checked_in_at_id IS NOT NULL
         AND apcn.next_node_id IS NULL
      JOIN name_tree_path ntp ON ntp.id = apcn.id
     ON apc_inst.name_id = n.id*/

    /*LEFT OUTER JOIN instance_note apc_type
    JOIN instance_note_key key3
      ON key3.id = apc_type.instance_note_key_id AND key3.name = 'Type'
      ON apc_type.instance_id = pro.id*/

    LEFT OUTER JOIN NAME firstHybridParent ON n.parent_id = firstHybridParent.id AND nt.hybrid
    LEFT OUTER JOIN NAME secondHybridParent ON n.second_parent_id = secondHybridParent.id AND nt.hybrid
  WHERE EXISTS(SELECT 1
               FROM INSTANCE
               WHERE name_id = n.id)
        AND n.duplicate_of_id IS NULL;
-- End APNI Names view

-- APC Taxon view
CREATE MATERIALIZED VIEW apctaxon AS

  SELECT
    /*n.id                                                    AS name_record_id,
    apc_inst.id                                                  AS apc_instance_id,*/
    'ICNAFP' :: TEXT                                      AS "nomenclaturalCode",
    CASE WHEN apcn.id IS NOT NULL
      THEN
        CASE WHEN apc_cited_inst.id IS NOT NULL
          THEN
            'http://id.biodiversity.org.au/instance/apni/' || apc_inst.id
        ELSE
          'http://id.biodiversity.org.au/node/apni/' || apcn.id
        END
    ELSE NULL END                                         AS "taxonID",

    nt.name                                               AS "nameType",
    'http://id.biodiversity.org.au/name/apni/' || n.id    AS "scientificNameID",

    n.full_name                                           AS "scientificName",

    CASE WHEN ns.name NOT IN ('legitimate', '[default]')
      THEN ns.name
    ELSE NULL END                                         AS "nomenclaturalStatus",

    CASE WHEN apc_inst.id = apcn.instance_id
      THEN
        apcn.type_uri_id_part
    ELSE
      apc_inst_type.name
    END                                                   AS "taxonomicStatus",
    apc_inst_type.pro_parte                               AS "proParte",

    CASE WHEN apc_inst.id != apcn.instance_id
      THEN
        accepted_name.full_name
    ELSE NULL END                                         AS "acceptedNameUsage",

    CASE WHEN apcn.instance_id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/node/apni/' || apcn.id
    ELSE NULL END                                         AS "acceptedNameUsageID",

    CASE WHEN apc_inst.id = apcn.instance_id AND apcp.id IS NOT NULL
      THEN
        CASE WHEN apcp.type_uri_id_part = 'classification-root'
          THEN '[APC]'
        ELSE
          'http://id.biodiversity.org.au/node/apni/' || apcp.id
        END
    ELSE NULL END                                         AS "parentNameUsageID",

    rank.name                                             AS "taxonRank",
    rank.sort_order                                       AS "taxonRankSortOrder",

    substring(ntp.rank_path FROM 'Regnum:([^>]*)')        AS "kingdom",
    substring(ntp.rank_path FROM 'Classis:([^>]*)')       AS "class",
    substring(ntp.rank_path FROM 'Subclassis:([^>]*)')    AS "subclass",
    substring(ntp.rank_path FROM 'Familia:([^>]*)')       AS "family",

    n.created_at                                          AS "created",
    n.updated_at                                          AS "modified",

    ARRAY(SELECT t2.label
          FROM name_tree_path ntp2 JOIN tree_arrangement t2 ON ntp2.tree_id = t2.id
          WHERE name_id = n.id
          ORDER BY t2.label)                              AS "datasetName",

    CASE WHEN apc_cited_inst.id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/instance/apni/' || apc_inst.cites_id
    ELSE
      'http://id.biodiversity.org.au/instance/apni/' || apc_inst.id
    END                                                   AS "taxonConceptID",

    CASE WHEN apcr.citation IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/reference/apni/' || apcr.id
    ELSE
      'http://id.biodiversity.org.au/reference/apni/' || apc_inst.reference_id
    END                                                   AS "nameAccordingToID",

    CASE WHEN apcr.citation IS NOT NULL
      THEN
        apcr.citation
    ELSE
      apc_ref.citation
    END                                                   AS "nameAccordingTo",

    /*apc_comment.value */
    (SELECT string_agg(regexp_replace(VALUE, E'[\\n\\r\\u2028]+', ' ', 'g' ),' ')
     FROM instance_note nt
       JOIN instance_note_key key1
         ON key1.id = nt.instance_note_key_id
            AND key1.name = 'APC Comment'
     WHERE nt.instance_id = apcn.instance_id)             AS "taxonRemarks",

    /*apc_dist.value*/
    (SELECT string_agg(regexp_replace(VALUE, E'[\\n\\r\\u2028]+', ' ', 'g' ),' ')
     FROM instance_note nt
       JOIN instance_note_key key1
         ON key1.id = nt.instance_note_key_id
            AND key1.name = 'APC Dist.'
     WHERE nt.instance_id = apcn.instance_id)             AS "taxonDistribution",

    CASE WHEN apc_inst.id = apcn.instance_id
      THEN regexp_replace(ntp.name_path, '\>', '|',
                          'g')
    ELSE NULL END                                         AS "higherClassification",

    'http://creativecommons.org/licenses/by/3.0/' :: TEXT AS "ccLicense",

    CASE WHEN apcn.id IS NOT NULL
      THEN
        CASE WHEN apc_cited_inst.id IS NOT NULL
          THEN
            'http://id.biodiversity.org.au/instance/apni/' || apc_inst.id
        ELSE
          'http://id.biodiversity.org.au/node/apni/' || apcn.id
        END
    ELSE NULL END                                         AS "ccAttributionIRI ",

    n.simple_name                                         AS "canonicalName",
    CASE WHEN nt.autonym
      THEN NULL
    ELSE
      regexp_replace(substring(n.full_name_html FROM '<authors>(.*)</authors>'), '<[^>]*>', '', 'g')
    END                                                   AS "scientificNameAuthorship",
    CASE WHEN firstHybridParent.id IS NOT NULL
      THEN
        firstHybridParent.full_name
    ELSE NULL END                                         AS "firstHybridParentName",

    CASE WHEN firstHybridParent.id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/name/apni/' || firstHybridParent.id
    ELSE NULL END                                         AS "firstHybridParentNameID",

    CASE WHEN secondHybridParent.id IS NOT NULL
      THEN
        secondHybridParent.full_name
    ELSE NULL END                                         AS "secondHybridParentName",

    CASE WHEN secondHybridParent.id IS NOT NULL
      THEN
        'http://id.biodiversity.org.au/name/apni/' || secondHybridParent.id
    ELSE NULL END                                         AS "secondHybridParentNameID"

  FROM INSTANCE apc_inst
    JOIN instance_type apc_inst_type ON apc_inst.instance_type_id = apc_inst_type.id
    JOIN REFERENCE apc_ref ON apc_ref.id = apc_inst.reference_id
    JOIN tree_node apcn
    JOIN tree_arrangement tree ON tree.id = apcn.tree_arrangement_id AND tree.label = 'APC'
      ON (apcn.instance_id = apc_inst.id OR apcn.instance_id = apc_inst.cited_by_id)
         AND apcn.checked_in_at_id IS NOT NULL
         AND apcn.next_node_id IS NULL
    /*JOIN tree_arrangement tree ON tree.id = apcn.tree_arrangement_id AND tree.label = 'APC'*/

    LEFT OUTER JOIN tree_link
    JOIN tree_node apcp
      ON apcp.id = tree_link.supernode_id
         AND apcp.checked_in_at_id IS NOT NULL
         AND apcp.next_node_id IS NULL
      ON apcn.id = tree_link.subnode_id

    LEFT OUTER JOIN INSTANCE apc_cited_inst ON apc_inst.cites_id = apc_cited_inst.id

    LEFT OUTER JOIN REFERENCE apcr ON apc_cited_inst.reference_id = apcr.id

    LEFT OUTER JOIN name_tree_path ntp ON ntp.id = apcn.id
    LEFT OUTER JOIN NAME accepted_name ON accepted_name.id = apcn.name_id

    JOIN NAME n ON n.id = apc_inst.name_id
    JOIN name_type nt ON n.name_type_id = nt.id
    JOIN name_status ns ON n.name_status_id = ns.id
    JOIN name_rank rank ON n.name_rank_id = rank.id

    /*LEFT OUTER JOIN instance_note apc_comment
    JOIN instance_note_key key1
      ON key1.id = apc_comment.instance_note_key_id AND key1.name = 'APC Comment'
      ON apc_comment.instance_id = apcn.instance_id*/

    /*LEFT OUTER JOIN instance_note apc_dist
    JOIN instance_note_key key2
      ON key2.id = apc_dist.instance_note_key_id AND key2.name = 'APC Dist.'
      ON apc_dist.instance_id = apcn.instance_id*/

    /*LEFT OUTER JOIN instance_note apc_type
    JOIN instance_note_key key3
      ON key3.id = apc_type.instance_note_key_id AND key3.name = 'Type'
      ON apc_type.instance_id = apcn.instance_id*/

    LEFT OUTER JOIN NAME firstHybridParent ON n.parent_id = firstHybridParent.id AND nt.hybrid
    LEFT OUTER JOIN NAME secondHybridParent ON n.second_parent_id = secondHybridParent.id AND nt.hybrid;

-- End APC Taxon