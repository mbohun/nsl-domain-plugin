package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(excludes = 'precedingName, precedingNameType')
class NamePart {

    Name name
    Name precedingName
    String precedingNameType

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        precedingNameType index: 'preceding_name_type_Index'
    }

    static constraints = {
        precedingNameType maxSize: 50
    }
}
