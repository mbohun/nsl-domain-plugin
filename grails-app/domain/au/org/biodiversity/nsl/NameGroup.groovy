package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString
class NameGroup {

    String name
    String rdfId
    String descriptionHtml

    static hasMany = [
            nameRanks              : NameRank,
            nameStatuses           : NameStatus,
            nameTypes              : NameType,
            nomenclaturalEventTypes: NomenclaturalEventType
    ]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name nullable: true, maxSize: 50, unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
