alter table tree_arrangement add owner varchar(255);

UPDATE db_version
SET version = 15
WHERE id = 1;
