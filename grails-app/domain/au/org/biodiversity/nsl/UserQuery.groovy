package au.org.biodiversity.nsl

import java.sql.Clob
import java.sql.Timestamp

class UserQuery {

    String searchModel
    String searchTerms
    Clob searchResult
    Timestamp searchStartedAt
    Timestamp searchFinishedAt
    String searchInfo
    BigDecimal recordCount
    Boolean queryCompleted
    Boolean queryStarted

    Timestamp createdAt
    Timestamp updatedAt

    Boolean trash = false

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        trash defaultvalue: "false"
        searchStartedAt sqlType: 'timestamp with time zone'
        searchFinishedAt sqlType: 'timestamp with time zone'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        searchModel nullable: true, maxSize: 4000
        searchTerms nullable: true, maxSize: 4000
        searchResult nullable: true
        searchStartedAt nullable: true
        searchFinishedAt nullable: true
        searchInfo nullable: true, maxSize: 500
    }
}
