package au.org.biodiversity.nsl

class ExternalRef {

    String objectType
    String externalIdSupplier
    String externalId
    BigDecimal originalProvider
    Instance instance
    Name name
    Reference reference

    static belongsTo = [Instance, Name, Reference]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
    }

    static constraints = {
        objectType nullable: true, maxSize: 50
        externalIdSupplier maxSize: 50
        externalId maxSize: 50
        originalProvider nullable: true
    }
}
