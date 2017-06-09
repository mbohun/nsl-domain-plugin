package au.org.biodiversity.nsl

import java.sql.Timestamp

class TreeVersion {

    Tree tree
    Boolean published = false
    TreeVersion previousVersion
    String draftName

    String logEntry
    String publishedBy
    Timestamp publishedAt

    static hasMany = [treeElements: TreeElement]
    static belongsTo = [Tree]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        published defaultvalue: "false"
        draftName sqlType: 'Text'
        publishedAt sqlType: 'timestamp with time zone'
        logEntry sqlType: 'Text'

    }

    static constraints = {
        draftName maxSize: 1000
        logEntry maxSize: 4000
        publishedBy maxSize: 100
    }
}
