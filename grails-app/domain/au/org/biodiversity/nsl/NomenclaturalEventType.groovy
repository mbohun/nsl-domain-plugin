package au.org.biodiversity.nsl

class NomenclaturalEventType {

    String nomenclaturalEventType
    NameGroup nameGroup
    String rdfId
    String descriptionHtml

    static belongsTo = [NameGroup]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        nomenclaturalEventType nullable: true, maxSize: 50
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
