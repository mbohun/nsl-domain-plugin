package au.org.biodiversity.nsl

class InstanceNoteKey {

    String name
    Integer sortOrder = 0
    Boolean deprecated = false
    String rdfId
    String descriptionHtml

    static hasMany = [citationTexts: InstanceNote]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        deprecated defaultValue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true, maxSize: 255
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    @Override
    String toString() {
        "Key $id: $name"
    }
}
