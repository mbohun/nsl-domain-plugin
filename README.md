## nsl-domain-plugin [![CircleCI](https://circleci.com/gh/mbohun/nsl-domain-plugin/tree/add_support_for-circleci.com.svg?style=svg)](https://circleci.com/gh/mbohun/nsl-domain-plugin/tree/add_support_for-circleci.com)

This is a grails plugin for the NSL project that maps the Domain objects of NSL. It is used to generate and update the
schema for the NSL.

## Considerations

When making schema changes we have to consider two cases:

- creating the schema for a new database
- modifying the schema in an existing database

and this means your changes need to appear in an update script and the nsl-ddl.sql file.
 
## Where to make your changes.

### Adding/Changing a view, trigger, index or default data 

If you are adding a view, trigger, index or default data:
 1. first add your changes to an appropriate file in the `/web-app/sql/views` directory
 1. run `grails generate-nsl-ddl` to regenerate the nsl-ddl.sql file with your changes included
 1. Add your change to the latest `update-to-nn.sql` file in the `/web-app/sql` directory

Remember the update-to-nn script is updating a database from the previous version, so you must take into account existing
views and **not loose data**.

### Adding or changing tables (domain objects)

If you are changing a table or tables you **must** make those changes in the Grails domain classes which will 
generate the appropriate sql when the `grails generate-nsl-ddl` command is run. This keeps the grails domain
classes,sql and DB schema in sync.

 1. make your changes to the grails domain classes in `/grails-app/domain/au/org/biodiversity/nsl`
 1. preferably test your changes using `grails maven install` locally
 1. run `grails generate-nsl-ddl` to regenerate the nsl-ddl.sql file with your changes included
 1. diff nsl-ddl.sql to extract changes to put into the latest `update-to-nn.sql` file in the `/web-app/sql` directory

## What version number

Make sure the version number you are working on is **not the currently released version**, if necessary create a new
version and update the default version number in `sql/views/other-setup.sql` as well as 
`grails-app/services/au/org/biodiversity/nsl/NslDomainService.groovy`.

##Notes

The simplest way to make the update sql is the re-generate the DDL from grails using the script:

`grails generate-nsl-ddl`

and `diff` the result to see what needs to be changed.

When starting off with a fresh NSL shard it's probably best to execute the nsl-ddl.sql file against your database 
(traditionally called nsl).

When writing `update-to-nn.sql` scripts we **try to make the update script idempotent**, so that if it is run twice (either 
deliberately or accidentaly) it results in the same thing. Note data loss is possible it the scripts are run again after 
a while.

## What is this?

This is part of the NSL (National Species List) Services Application developed at the Australian National Botanic Gardens in
association with CHAH, the ALA and the IBIS team.

This code is Licensed under the Apache 2 License and we welcome contributions from the taxonomic community.

Please use Github issues for any bug reports.
