package au.org.biodiversity.nsl

class Locale {

    String localeNameString

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
    }

    static constraints = {
        localeNameString maxSize: 50, unique: true
    }
}
