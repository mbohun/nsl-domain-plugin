ALTER TABLE instance ADD CONSTRAINT citescheck CHECK (cites_id IS NULL OR cited_by_id IS NOT NULL);

CREATE INDEX name_lower_f_unaccent_full_name_like ON name (lower(f_unaccent(full_name)) varchar_pattern_ops);

CREATE INDEX ref_citation_text_index ON reference USING gin(to_tsvector('english'::regconfig,f_unaccent(coalesce((citation)::text,''::text))));

INSERT INTO db_version (id, version) VALUES (1, 11);
