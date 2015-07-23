package au.org.biodiversity.nsl

import java.sql.Timestamp

class InstanceNote {

    Instance instance
    InstanceNoteKey instanceNoteKey
    String value

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Namespace namespace

    Boolean trash = false

    static belongsTo = [Instance, InstanceNoteKey]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        trash defaultvalue: "false"

        sourceId index: 'Note_Source_Index'
        sourceIdString index: 'Note_Source_String_Index'
        sourceSystem index: 'Note_Source_Index,Note_System_Index'
        namespace index: 'Note_Source_Index'

        instance index: 'Note_Instance_Index'
        instanceNoteKey index: 'Note_Key_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        value maxSize: 4000

        updatedBy maxSize: 50
        createdBy maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    @Override
    String toString() {
        "Text $id: ${instanceNoteKey.name}; $value"
    }
}
