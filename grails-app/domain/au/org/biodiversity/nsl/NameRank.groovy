package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = 'abbrev')
class NameRank {

    String abbrev
    String name
    Boolean deprecated = false
    Boolean visibleInName = true
    Boolean italicize = false
    Boolean major = false
    Integer sortOrder = 0
    NameGroup nameGroup
    NameRank parentRank
    Boolean hasParent = false
    String rdfId
    String descriptionHtml

    static hasMany = [names: Name]
    static belongsTo = [NameGroup]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        deprecated defaultvalue: "false"
        visibleInName defaultValue: "true"
        italicize defaultvalue: "false"
        major defaultvalue: "false"
        hasParent defaultValue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        abbrev maxSize: 20
        name maxSize: 50
        sortOrder min: 0, max: 500
        parentRank nullable: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
