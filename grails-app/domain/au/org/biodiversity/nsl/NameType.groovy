package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = 'name')
class NameType {

    String name
    Boolean hybrid = false
    Boolean autonym = false
    Boolean formula = false
    Boolean scientific = false
    Boolean cultivar = false
    Boolean deprecated = false
    Integer sortOrder = 0
    String connector
    NameGroup nameGroup
    NameCategory nameCategory
    String rdfId
    String descriptionHtml

    static hasMany = [names: Name]
    static belongsTo = [NameCategory, NameGroup]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        deprecated defaultvalue: "false"
        hybrid defaultvalue: "false"
        autonym defaultvalue: "false"
        formula defaultvalue: "false"
        scientific defaultvalue: "false"
        cultivar defaultvalue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        sortOrder min: 0, max: 500
        connector maxSize: 1, nullable: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
