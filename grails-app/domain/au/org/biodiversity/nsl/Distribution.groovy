package au.org.biodiversity.nsl

class Distribution {

    String description
    String region
    boolean isNative = false
    boolean isNaturalised = false
    boolean isDoubtfullyNaturalised = false
    boolean isExtinct = false

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        isNative defaultvalue: false
        isNaturalised defaultvalue: false
        isDoubtfullyNaturalised defaultvalue: false
        isExtinct defaultvalue: false
    }

    static constraints = {
        description maxSize: 100
        region maxSize: 10
    }
}
