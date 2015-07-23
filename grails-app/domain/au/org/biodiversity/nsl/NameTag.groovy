package au.org.biodiversity.nsl

/**
 * NameTag is a generic tag that can be applied to names. Names can have as many unique tags applied as required.
 * A tag does not imply any specific meaning within the system and is only used for categorisation by people.
 */
class NameTag {

    String name

    static hasMany = [names: NameTagName]

    static mapping = {
        datasource 'nsl'
        version column: 'lock_version', defaultValue: "0"

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
    }

    static constraints = {
        name unique: true
    }
}
