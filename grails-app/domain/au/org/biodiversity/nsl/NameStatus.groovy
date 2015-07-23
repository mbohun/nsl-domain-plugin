package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = "name")
class NameStatus {

    String name
    Boolean nomIlleg
    Boolean nomInval
    NameStatus nameStatus
    NameGroup nameGroup
    Boolean display = true
    String rdfId
    String descriptionHtml

    static hasMany = [
            nameStatuses: NameStatus,
            names       : Name
    ]
    static belongsTo = [NameGroup]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        display defaultValue: "true"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name nullable: true, maxSize: 50, unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
