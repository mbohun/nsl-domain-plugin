package au.org.biodiversity.nsl

class ShardConfig {

    String name
    String value

    static mapping = {
        datasource 'nsl'
        version(false)
    }

    static constraints = {
        name unique: true
    }
}
