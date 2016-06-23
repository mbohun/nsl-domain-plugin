alter table instance_type add COLUMN has_label varchar(255) not null DEFAULT 'not set';
alter table instance_type add COLUMN of_label varchar(255) not null DEFAULT 'not set';

update instance_type set has_label = name where misapplied = false;
update instance_type set of_label = name || ' of' where misapplied = false;
update instance_type set has_label = regexp_replace(name, 'misapplied', 'misapplication') where misapplied = true;
update instance_type set of_label = name || ' to' where misapplied = true;

-- version
UPDATE db_version
SET version = 17
WHERE id = 1;

