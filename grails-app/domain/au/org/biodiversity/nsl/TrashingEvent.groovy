package au.org.biodiversity.nsl

import java.sql.Timestamp

class TrashingEvent {

    String createdBy
    String updatedBy
    Timestamp createdAt
    Timestamp updatedAt

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        createdBy maxSize: 4000
        updatedBy maxSize: 4000
    }
}
