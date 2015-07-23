package au.org.biodiversity.nsl

import java.sql.Clob
import java.sql.Timestamp

class HelpTopic {

    String name
    Clob markedUpText
    Integer sortOrder = 0

    String createdBy
    String updatedBy
    Timestamp createdAt
    Timestamp updatedAt

    Boolean trash = true

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        trash defaultvalue: "false"
        sortOrder defaultValue: "0"
    }

    static constraints = {
        name maxSize: 4000
        createdBy maxSize: 4000
        updatedBy maxSize: 4000
        sortOrder min: 0, max: 500
    }
}
