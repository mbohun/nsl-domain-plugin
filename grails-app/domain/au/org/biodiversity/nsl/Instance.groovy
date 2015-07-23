package au.org.biodiversity.nsl

import java.sql.Timestamp

class Instance {

    String verbatimNameString
    String page
    String pageQualifier
    String nomenclaturalStatus
    String bhlUrl

    InstanceType instanceType
    Name name
    Reference reference
    Instance parent
    Instance cites
    Instance citedBy
    Boolean validRecord = false
    Boolean draft = false

    Long sourceId
    String sourceSystem
    String sourceIdString
    Namespace namespace

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    Boolean trash = false

    static hasMany = [
            externalRefs       : ExternalRef,
            instancesForCitedBy: Instance,
            instancesForCites  : Instance,
            instancesForParent : Instance,
            instanceNotes      : InstanceNote,
            comments           : Comment
    ]
    static belongsTo = [Name, Namespace, Reference]

    static mappedBy = [
            instancesForCitedBy: "citedBy",
            instancesForCites  : "cites",
            instancesForParent : "parent",
            comments           : "instance"
    ]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        validRecord defaultvalue: "false"
        draft defaultvalue: "false"
        trash defaultvalue: "false"

        sourceId index: 'Instance_Source_Index'
        sourceIdString index: 'Instance_Source_String_Index'
        sourceSystem index: 'Instance_Source_Index,Instance_System_Index'
        namespace index: 'Instance_Source_Index'

        //FK indexes
        instanceType index: 'Instance_InstanceType_Index'
        name index: 'Instance_Name_Index'
        reference index: 'Instance_Reference_Index'
        parent index: 'Instance_Parent_Index'
        cites index: 'Instance_Cites_Index'
        citedBy index: 'Instance_CitedBy_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        verbatimNameString nullable: true
        page nullable: true
        pageQualifier nullable: true
        nomenclaturalStatus nullable: true, maxSize: 50
        bhlUrl nullable: true, maxSize: 4000

        updatedBy maxSize: 1000
        createdBy maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    @Override
    String toString() {
        "Inst $id: ${verbatimNameString ?: name}; $instanceType.name"
    }
}
