alter table name_status add column deprecated boolean default false not null;

-- version
UPDATE db_version
SET version = 21
WHERE id = 1;
