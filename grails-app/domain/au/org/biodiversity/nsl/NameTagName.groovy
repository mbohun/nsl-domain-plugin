package au.org.biodiversity.nsl

import java.sql.Timestamp

/**
 * NameTagName is an explicit join table for Name to NameTag so we can use it in HQL properly
 */
class NameTagName implements Serializable {

    Name name
    NameTag tag

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    static mapping = {
        datasource 'nsl'
        id composite: ['name', 'tag']
        version(false)
        name index: 'Name_Tag_Name_Index'
        tag index: 'Name_Tag_Tag_Index'

        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {

    }
}
