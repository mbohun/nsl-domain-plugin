grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"

grails.project.fork = [
        // configure settings for compilation JVM, note that if you alter the Groovy version forked compilation is required
        //  compile: [maxMemory: 256, minMemory: 64, debug: false, maxPerm: 256, daemon:true],

        // configure settings for the test-app JVM, uses the daemon by default
        test   : [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, daemon: true],
        // configure settings for the run-app JVM
        run    : [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve: false],
        // configure settings for the run-war JVM
        war    : [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256, forkReserve: false],
        // configure settings for the Console UI JVM
        console: [maxMemory: 768, minMemory: 64, debug: false, maxPerm: 256]
]

grails.project.dependency.resolver = "maven" // or ivy
grails.project.repos.default = "anbg_snapshots"

// edit your ~/.grails/settings.groovy to point to your own nexus repo with appropriate URL and authentication

//grails.project.repos.anbg_snapshots.url = "http://host:port/nexus/content/repositories/snapshots/"
//grails.project.repos.anbg_snapshots.username = "fred"
//grails.project.repos.anbg_snapshots.password = "secret"
//
//grails.project.repos.anbg_releases.url = "http://host:port/nexus/content/repositories/releases/"
//grails.project.repos.anbg_releases.username = "fred"
//grails.project.repos.anbg_releases.password = "secret"

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }

    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'

    repositories {

        mavenLocal()
        mavenRepo(id: "anbg", url: "http://155.187.10.62:8081/nexus/content/groups/public/") {
            updatePolicy "interval:1"
        }
        mavenRepo(id: "anbg", url: "http://155.187.10.62:8081/nexus/content/repositories/grails-plugins")
        grailsHome()
    }

    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
        // runtime 'mysql:mysql-connector-java:5.1.27'
        runtime 'org.postgresql:postgresql:9.3-1101-jdbc41'

    }

    plugins {

        // plugins for the compile step
        compile ':cache:1.1.7'

        // plugins needed at runtime but not for compilation
        runtime(":hibernate4:4.3.5.5",
                ":database-migration:1.4.0",
                ":jquery:1.11.1",
                ":jquery-ui:1.10.4"
        ) {
            export = false
        }


        build(":release:3.0.1",
                ":rest-client-builder:2.0.3",
                ":tomcat:7.0.55") {
            export = false
        }
    }
}
