includeTargets << grailsScript("_GrailsInit")
includeTargets << new File("${grailsSettings.projectPluginsDir}/hibernate4-4.3.5.5/scripts/SchemaExport.groovy")

target(main: "Generate the NSL ddl sql from the current schema including views") {
    //schema-export --datasource=nsl
    argsMap.datasource = 'nsl'
    schemaExport()
    File ddl = new File("${grailsSettings.projectTargetDir}/ddl.sql")
    String text = ddl.text
                     .replaceAll(/alter table/, 'alter table if exists')
                     .replaceAll(/drop constraint/, 'drop constraint if exists')
                     .replaceAll(/boolean not null/, 'boolean default false not null')
                     .replaceAll(/create sequence nsl_global_seq;/, '')
                     .replaceAll(/drop sequence nsl_global_seq;/, 'drop sequence nsl_global_seq;\n    create sequence nsl_global_seq minvalue 1000 maxvalue 10000000;')
    File dataDir = new File("${grailsSettings.baseDir}/web-app/sql")
    File viewsDir = new File(dataDir, 'views')
    File nslDdl = new File(dataDir, "nsl-ddl.sql")
    nslDdl.write(text)
    viewsDir.listFiles().each{ File view ->
        nslDdl.append(view.text)
    }
}

setDefaultTarget(main)
