package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = ['name'])
class RefType {

    String name
    Boolean parentOptional
    RefType parent
    String rdfId
    String descriptionHtml

    static hasMany = [refTypes  : RefType,
                      references: Reference]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name maxSize: 50, unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
