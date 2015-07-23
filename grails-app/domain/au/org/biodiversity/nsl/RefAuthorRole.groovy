package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString
class RefAuthorRole {

    String name
    String rdfId
    String descriptionHtml

    static hasMany = [references: Reference]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
