package au.org.biodiversity.nsl

import java.sql.Timestamp

class Author {

    String abbrev
    String name
    String fullName
    String dateRange
    String notes
    String ipniId
    Author duplicateOf
    Boolean validRecord = false

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Boolean trash = false

    Namespace namespace

    static hasMany = [namesForAuthor           : Name,
                      namesForBaseAuthor       : Name,
                      namesForExAuthor         : Name,
                      namesForExBaseAuthor     : Name,
                      namesForSanctioningAuthor: Name,
                      references               : Reference,
                      comments                 : Comment
    ]
    static belongsTo = [Namespace]

    static mappedBy = [namesForAuthor           : "author",
                       namesForBaseAuthor       : "baseAuthor",
                       namesForExAuthor         : "exAuthor",
                       namesForExBaseAuthor     : "exBaseAuthor",
                       namesForSanctioningAuthor: "sanctioningAuthor",
                       comments                 : "author"
    ]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        validRecord defaultvalue: "false"
        trash defaultvalue: "false"

        sourceId index: 'Auth_Source_Index'
        sourceIdString index: 'Auth_Source_String_Index'
        sourceSystem index: 'Auth_Source_Index,Auth_System_Index'
        namespace index: 'Auth_Source_Index'

        abbrev index: 'Author_Abbrev_Index'
        name index: 'Author_Name_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'

    }

    static constraints = {
        abbrev nullable: true, maxSize: 100
        name nullable: true
        fullName nullable: true
        dateRange nullable: true, maxSize: 50
        notes nullable: true, maxSize: 1000
        ipniId nullable: true, maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    @Override
    public String toString() {
        return "Author $id: ${name ?: abbrev}"
    }
}
