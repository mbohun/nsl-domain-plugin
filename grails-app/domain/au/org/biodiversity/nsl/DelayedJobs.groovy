package au.org.biodiversity.nsl

import java.sql.Clob
import java.sql.Timestamp

class DelayedJobs {

    BigDecimal priority
    BigDecimal attempts
    Clob handler
    Clob lastError
    Timestamp runAt
    Timestamp lockedAt
    Timestamp failedAt
    String lockedBy
    String queue
    Timestamp createdAt
    Timestamp updatedAt

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        runAt sqlType: 'timestamp with time zone'
        lockedAt sqlType: 'timestamp with time zone'
        failedAt sqlType: 'timestamp with time zone'


        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        priority nullable: true
        attempts nullable: true
        handler nullable: true
        lastError nullable: true
        runAt nullable: true
        lockedAt nullable: true
        failedAt nullable: true
        lockedBy nullable: true, maxSize: 4000
        queue nullable: true, maxSize: 4000
    }
}
