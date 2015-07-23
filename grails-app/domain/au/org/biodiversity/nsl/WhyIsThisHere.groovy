package au.org.biodiversity.nsl

class WhyIsThisHere {

    String name
    Integer sortOrder = 0

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
    }

    static constraints = {
        name maxSize: 50, unique: true
        sortOrder min: 0, max: 500
    }

}
