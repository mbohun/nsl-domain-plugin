alter table instance ADD CONSTRAINT citescheck check (cites_id is null or cited_by_id is not null);

create index name_lower_f_unaccent_full_name_like on name (lower(f_unaccent(full_name)) varchar_pattern_ops);

insert into db_version (id, version) values (1, 10);