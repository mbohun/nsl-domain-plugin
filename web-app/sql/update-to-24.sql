-- new tree structure

-- old
alter table if exists tree
  drop constraint if exists FK_smitro8m4hxw85sm5c6vvbd7t;

alter table if exists tree
  drop constraint if exists FK_sn8jtgc2ga18vl1vqq6srjdx9;
-- new
alter table if exists tree
  drop constraint if exists FK_svg2ee45qvpomoer2otdc5oyc;

alter table if exists tree
  drop constraint if exists FK_48skgw51tamg6ud4qa8oh0ycm;
--

alter table if exists tree_version
  drop constraint if exists FK_tiniptsqbb5fgygt1idm1isfy;

alter table if exists tree_version
  drop constraint if exists FK_4q3huja5dv8t9xyvt5rg83a35;

alter table if exists tree_element
  drop constraint if exists FK_tb2tweovvy36a4bgym73jhbbk;

alter table if exists tree_element
  drop constraint if exists FK_slpx4w0673tudgw4fcodauilv;

alter table if exists tree_element
  drop constraint if exists FK_89rcrnlb8ed10mgp22d3cj646;

--old
alter table if exists tree_element
  drop constraint if exists FK_bxv8f6p0bemojla1j8po0g7y3;

alter table if exists tree_element
  drop constraint if exists FK_6eu6l7khjvp6c7ii0yqyger21;
-- new
alter table if exists tree_element
  drop constraint if exists FK_964uyddp8ju1ya5v2px9wx5tf;

alter table if exists tree_element
  drop constraint if exists FK_kaotdsllnfojld6pdxb8c9gml;
--

DROP TABLE if EXISTS distribution;
create table distribution (
  id int8 default nextval('nsl_global_seq') not null,
  lock_version int8 default 0 not null,
  description varchar(100) not null,
  is_doubtfully_naturalised boolean default false not null,
  is_extinct boolean default false not null,
  is_native boolean default false not null,
  is_naturalised boolean default false not null,
  region varchar(10) not null,
  primary key (id)
);

DROP TABLE IF EXISTS tree;
create table tree (
  id int8 default nextval('nsl_global_seq') not null,
  lock_version int8 default 0 not null,
  current_tree_version_id int8,
  default_draft_tree_version_id int8,
  group_name Text not null,
  name Text not null,
  primary key (id)
);

DROP TABLE IF EXISTS  tree_version;
create table tree_version (
  id int8 default nextval('nsl_global_seq') not null,
  lock_version int8 default 0 not null,
  draft_name Text not null,
  log_entry Text ,
  previous_version_id int8,
  published boolean default false not null,
  published_at timestamp with time zone,
  published_by varchar(100),
  tree_id int8 not null,
  primary key (id)
);

DROP TABLE IF EXISTS tree_element;
create table tree_element (
  tree_version_id int8 not null,
  tree_element_id int8 not null,
  lock_version int8 default 0 not null,
  display_string Text not null,
  element_link Text not null,
  instance_id int8 not null,
  instance_link Text not null,
  name_id int8 not null,
  name_link Text not null,
  name_path Text not null,
  parent_Version_Id int8,
  parent_Element_Id int8,
  previous_Version_Id int8,
  previous_Element_Id int8,
  profile jsonb,
  rank_path jsonb,
  simple_name Text not null,
  tree_path Text not null,
  updated_at timestamp with time zone not null,
  updated_by varchar(255) not null,
  primary key (tree_version_id, tree_element_id)
);

alter table if exists tree
  add constraint FK_svg2ee45qvpomoer2otdc5oyc
foreign key (current_tree_version_id)
references tree_version;

alter table if exists tree
  add constraint FK_48skgw51tamg6ud4qa8oh0ycm
foreign key (default_draft_tree_version_id)
references tree_version;

alter table if exists tree_element
  add constraint FK_tb2tweovvy36a4bgym73jhbbk
foreign key (tree_version_id)
references tree_version;

alter table if exists tree_element
  add constraint FK_slpx4w0673tudgw4fcodauilv
foreign key (instance_id)
references instance;

alter table if exists tree_element
  add constraint FK_89rcrnlb8ed10mgp22d3cj646
foreign key (name_id)
references name;

alter table if exists tree_element
  add constraint FK_964uyddp8ju1ya5v2px9wx5tf
foreign key (parent_Version_Id, parent_Element_Id)
references tree_element;

alter table if exists tree_element
  add constraint FK_kaotdsllnfojld6pdxb8c9gml
foreign key (previous_Version_Id, previous_Element_Id)
references tree_element;

alter table if exists tree_version
  add constraint FK_tiniptsqbb5fgygt1idm1isfy
foreign key (previous_version_id)
references tree_version;

alter table if exists tree_version
  add constraint FK_4q3huja5dv8t9xyvt5rg83a35
foreign key (tree_id)
references tree;


-- version
UPDATE db_version
SET version = 24
WHERE id = 1;

