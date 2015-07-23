package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(excludes = 'sortOrder')
class NameCategory {

    String name
    Integer sortOrder = 0
    String rdfId
    String descriptionHtml

    static hasMany = [nameTypes: NameType]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name maxSize: 50, unique: true
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
