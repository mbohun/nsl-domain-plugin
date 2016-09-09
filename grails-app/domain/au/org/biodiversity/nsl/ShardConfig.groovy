package au.org.biodiversity.nsl

class ShardConfig {

    String name
    String value

    static mapping = {
        datasource 'nsl'
        version(false)
        id generator: 'native', params: [sequence: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"
    }

    static constraints = {
        name unique: true
        value maxSize: 5000
    }
}
