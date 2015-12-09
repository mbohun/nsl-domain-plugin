This is a grails plugin for the NSL project that maps the Domain objects of NSL. It is used to generate and update the
schema for the NSL.

When making changes we currently create an update-to-#.sql file inside web-app/sql to document the changes.

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