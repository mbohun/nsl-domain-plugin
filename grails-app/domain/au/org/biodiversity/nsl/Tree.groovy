package au.org.biodiversity.nsl

class Tree {

    String name
    String groupName  //the role group that owns/edits this tree
    TreeVersion defaultDraftTreeVersion
    TreeVersion currentTreeVersion
    Long referenceId  // an unconstrained FK to Reference for in-reference trees only.

    static hasMany = [treeVersions: TreeVersion]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        name sqlType: 'Text'
        groupName sqlType: 'Text'
    }

    static constraints = {
        name maxSize: 1000  //because it may be a citation
        groupName maxSize: 100
        currentTreeVersion nullable: true
        defaultDraftTreeVersion nullable: true
        referenceId nullable: true
    }
}
