package au.org.biodiversity.nsl

import java.sql.Timestamp

class Reference {

    String doi
    String title
    String displayTitle
    String abbrevTitle
    Integer year
    String volume
    String edition
    String pages
    String verbatimReference
    String verbatimCitation
    String verbatimAuthor
    String citation
    String citationHtml
    String notes
    Boolean published
    String publisher
    String publishedLocation
    String publicationDate
    String isbn
    String issn
    String bhlUrl
    String tl2
    RefType refType

    Reference parent
    Author author

    RefAuthorRole refAuthorRole
    Reference duplicateOf
    Language language
    Boolean validRecord = false

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Namespace namespace

    Boolean trash = false

    static hasMany = [
            externalRefs            : ExternalRef,
            instances               : Instance,
            referencesForDuplicateOf: Reference,
            referencesForParent     : Reference,
            comments                : Comment
    ]
    static belongsTo = [Language, Namespace, RefAuthorRole, RefType]

    static mappedBy = [
            referencesForDuplicateOf: "duplicateOf",
            referencesForParent     : "parent",
            comments                : "reference"
    ]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        validRecord defaultvalue: "false"
        trash defaultvalue: "false"

        sourceId index: 'Ref_Source_Index'
        sourceIdString index: 'Ref_Source_String_Index'
        sourceSystem index: 'Ref_Source_Index,Ref_System_Index'
        namespace index: 'Ref_Source_Index'

        //FK indexes
        refType index: 'Reference_Type_Index'
        parent index: 'Reference_Parent_Index'
        author index: 'Reference_Author_Index'
        refAuthorRole index: 'Reference_AuthorRole_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        doi nullable: true, unique: true
        title maxSize: 2000
        displayTitle maxSize: 2000
        abbrevTitle nullable: true, maxSize: 2000
        year nullable: true, min: 0, max: 2999
        volume nullable: true, maxSize: 50
        edition nullable: true, maxSize: 50
        pages nullable: true, maxSize: 100
        verbatimReference nullable: true, maxSize: 1000
        verbatimCitation nullable: true, maxSize: 2000
        verbatimAuthor nullable: true, maxSize: 1000
        notes nullable: true, maxSize: 1000
        publisher nullable: true, maxSize: 100
        publishedLocation nullable: true, maxSize: 50
        publicationDate nullable: true, maxSize: 50
        isbn nullable: true, maxSize: 16
        issn nullable: true, maxSize: 16
        bhlUrl nullable: true, maxSize: 4000
        tl2 nullable: true, maxSize: 30
        citation nullable: true, maxSize: 512
        citationHtml nullable: true, maxSize: 512

        updatedBy maxSize: 1000
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    @Override
    String toString() {
        List<String> bits = ["Reference $id: ($refType.name);"]
        bits << "${displayTitle == 'Not set' ? '' : displayTitle} (${year ?: publicationDate});"
        bits << "${author ?: ''};"
        bits << "${parent ?: ''}"
        return bits.join(' ')
    }

}
