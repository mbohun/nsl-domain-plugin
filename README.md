This is a grails plugin for the NSL project that maps the Domain objects of NSL. It is used to generate and update the
schema for the NSL.

## Making schema changes

When making schema changes we have to consider two cases:

- modifying the schema in an existing database
- creating the schema in a new database

and this means you have to enter your schema changes in two places.

### Modifying an existing database

Add your change to the latest update-to-nn.sql file in `web-app/sql'.  
E.g. `update-to-21.sql`

We run the latest update-to-nn.sql against each database during promotion.

### Setting up a new database

Add your change to the *appropriate* component file in `web-app/sql/views`.

E.g. 
 - web-app/sql/views/search-views.sql has search views,
 - web-app/sql/views/triggers.sql has triggers...


## Notes

**Don't forget to update the default version number in sql/views/other-setup.sql as well as 
grails-app/services/au/org/biodiversity/nsl/NslDomainService.groovy*s*

The simplest way to make the update sql is the re-generate the DDL from grails using the script:

grails generate-nsl-ddl

which will generate the schema from the domain classes and add the sql files in the web-apps/sql/views directory. The 
sql in the web-apps/sql/views directory is used to add views, extra indexes, and initialization code.

When starting off with a fresh NSL shard it's probably best to execute the nsl-ddl.sql file against your database 
(traditionally called nsl).

This is part of the NSL (National Species List) Services Application developed at the Australian National Botanic Gardens in
association with CHAH, the ALA and the IBIS team.

This code is Licensed under the Apache 2 License and we welcome contributions from the taxonomic community.

Please use Github issues for any bug reports.
