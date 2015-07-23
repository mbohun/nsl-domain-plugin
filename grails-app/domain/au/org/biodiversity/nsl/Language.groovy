package au.org.biodiversity.nsl

class Language {

    String iso6391Code
    String iso6393Code
    String name

    static hasMany = [references: Reference]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
    }

    static constraints = {
        iso6391Code nullable: true, maxSize: 2, unique: true
        iso6393Code maxSize: 3, unique: true
        name maxSize: 50, unique: true
    }

    @Override
    public String toString() {
        return "Language { $id, $name }"
    }
}
