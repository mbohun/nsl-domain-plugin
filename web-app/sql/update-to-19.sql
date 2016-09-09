DROP TABLE IF EXISTS shard_config;

CREATE TABLE shard_config (
  id    INT8 DEFAULT nextval('hibernate_sequence') NOT NULL,
  name  VARCHAR(255)                               NOT NULL,
  value VARCHAR(5000)                              NOT NULL,
  PRIMARY KEY (id)
);
-- add back the defaults, which will need to be configured per shard
INSERT INTO public.shard_config (id, name, value) VALUES
  (nextval('hibernate_sequence'), 'config rules', 'All lower case names, space separated, follow the pattern hierachy');
INSERT INTO public.shard_config (id, name, value) VALUES (nextval('hibernate_sequence'), 'name space', 'APNI');
INSERT INTO public.shard_config (id, name, value) VALUES (nextval('hibernate_sequence'), 'name tree label', 'APNI');
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'classification tree label', 'APC');

-- add default descriptions
INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'APNI description',
        'The Australian Plant Name Index (APNI) is a tool for the botanical community that deals with plant names and their usage in the scientific literature, whether as a current name or synonym. APNI does not recommend any particular taxonomy or nomenclature. For a listing of currently accepted scientific names for the Australian vascular flora, please use the Australian Plant Census (APC) link above.');

INSERT INTO public.shard_config (id, name, value)
VALUES (nextval('hibernate_sequence'), 'APC description',
        'The Australian Plant Census (APC) is a list of the accepted scientific names for the Australian vascular flora, ferns, gymnosperms, hornworts and liverworts, both native and introduced, and includes synonyms and misapplications for these names. The APC covers all published scientific plant names used in an Australian context in the taxonomic literature, but excludes taxa known only from cultivation in Australia. The taxonomy and nomenclature adopted for the APC are endorsed by the Council of Heads of Australasian Herbaria (CHAH).');

-- version
UPDATE db_version
SET version = 19
WHERE id = 1;
