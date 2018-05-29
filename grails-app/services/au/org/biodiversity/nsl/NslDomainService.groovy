/*
    Copyright 2015 Australian National Botanic Gardens

    This file is part of NSL-domain-plugin.

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
    of the License at http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
package au.org.biodiversity.nsl

import groovy.sql.Sql
import groovy.text.SimpleTemplateEngine
import org.codehaus.groovy.grails.plugins.GrailsPlugin
import org.hibernate.SessionFactory

class NslDomainService {
    def pluginManager
    def grailsApplication
    SessionFactory sessionFactory_nsl

    static final Integer currentVersion = 25

    File getDdlFile() {
        File pluginDir = getPluginDirectory()
        File file = new File(pluginDir, "sql/nsl-ddl.sql")
        log.info "nsl-ddl.sql file path $file.absolutePath"
        return file
    }

    Boolean checkUpToDate() {
        try {
            DbVersion.get(1)?.version == currentVersion
        } catch (e) {
            log.error e.message
            return false
        }
    }

    /**
     * update the database to the current version using update scripts
     * @return true if worked
     */
    Boolean updateToCurrentVersion(Sql sql, Map params) {
        Integer dbVersion = DbVersion.get(1)?.version
        if (!dbVersion) {
            log.error "Database version not found, not updating."
            return false
        }
        sessionFactory_nsl.getCurrentSession().flush()
        sessionFactory_nsl.getCurrentSession().clear()
        for (Integer versionNumber in ((dbVersion + 1)..currentVersion)) {
            log.info "updating to version $versionNumber"
            File updateFile = getUpdateFile(versionNumber)
            params.putAll(getParamsFile(versionNumber))
            if (updateFile?.exists()) {
                String sqlSource = updateFile.text.replaceAll('\\$\\$', 'DollarDelimit')
                                             .replaceAll('\\$do\\$', 'DollarDoDelimit')
                def engine = new SimpleTemplateEngine()
                def template = engine.createTemplate(sqlSource).make(params)
                sqlSource = template.toString().replaceAll('DollarDelimit', '\\$\\$')
                                    .replaceAll('DollarDoDelimit', '\\$do\\$')
                log.debug sqlSource
                sql.execute(sqlSource) { isResultSet, result ->
                    if (isResultSet) log.debug result
                }
            }
        }
        sessionFactory_nsl.getCurrentSession().flush()
        sessionFactory_nsl.getCurrentSession().clear()
        log.info "Update complete"
        return checkUpToDate()
    }

    Map getParamsFile(Integer versionNumber) {
        File updatesDir = new File(grailsApplication.config.updates.dir.toString())
        File file = new File(updatesDir, "update-to-${versionNumber}-params.groovy")
        if (file?.exists()) {
            Map params = new GroovyShell().evaluate(file.text, 'Updater.groovy') as Map
            return params
        }
        return [:]
    }

    File getUpdateFile(Integer versionNumber) {
        File pluginDir = getPluginDirectory()
        File file = new File(pluginDir, "sql/update-to-${versionNumber}.sql")
        log.info "nsl-ddl.sql file path $file.absolutePath"
        return file
    }

    private File getPluginDirectory() {
        GrailsPlugin plugin = pluginManager.allPlugins.find { it.name.startsWith('nslDomain') }
        log.info "found $plugin.name with path ${plugin.pluginPath}"
        return grailsApplication.mainContext.getResource(plugin.pluginPath).file
    }
}
