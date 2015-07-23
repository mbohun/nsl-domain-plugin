package au.org.biodiversity.nsl

import org.codehaus.groovy.grails.plugins.GrailsPlugin

class NslDomainService {
    def pluginManager
    def grailsApplication

    static final Integer currentVersion = 8

    File getDdlFile() {
        GrailsPlugin plugin = pluginManager.allPlugins.find { it.name.startsWith('nslDomain') }
        log.info "found $plugin.name with path ${plugin.pluginPath}"
        File pluginDir = grailsApplication.mainContext.getResource(plugin.pluginPath).file
        File file = new File(pluginDir, "sql/nsl-ddl.sql")
        log.info "nsl-ddl.sql file path $file.absolutePath"
        return file
    }

    def checkUpToDate() {
        try {
            DbVersion.get(1)?.version == currentVersion
        } catch (e) {
            log.error e.message
            return false
        }
    }
}
