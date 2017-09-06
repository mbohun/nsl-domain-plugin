package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType

import java.security.Timestamp

class TreeElement {

    TreeElement previousElement
    TreeElement parentElement

    Long instanceId          //unconstrained FK to the instance - depends on the shard
    Long nameId              //unconstrained FK to the name - depends on the shard
    Boolean excluded = false //is this an excluded concept

    String displayHtml
    String synonymsHtml
    String simpleName
    String nameElement
    String treePath
    String namePath
    String rank
    Integer depth = 0
    String sourceShard      //where the taxon comes from
    Map synonyms
    Map rankPath
    Map profile

    String sourceElementLink //Link to the source tree element for composed trees
    String nameLink
    String instanceLink

    String updatedBy
    Timestamp updatedAt

    static hasMany = [treeVersionElements: TreeVersionElement]

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        updatedAt sqlType: 'timestamp with time zone'
        displayHtml sqlType: 'Text'
        synonymsHtml sqlType: 'Text'
        simpleName sqlType: 'Text', index: "tree_simple_name_index"
        treePath sqlType: 'Text', index: "tree_path_index"
        namePath sqlType: 'Text', index: "tree_name_path_index"
        sourceShard sqlType: 'Text'
        nameLink sqlType: 'Text'
        instanceLink sqlType: 'Text'
        sourceElementLink sqlType: 'Text'
        synonyms type: JsonbMapType
        rankPath type: JsonbMapType
        profile type: JsonbMapType
        excluded defaultValue: false
        depth defaultValue: 0
    }

    static constraints = {
        previousElement nullable: true
        parentElement nullable: true
        sourceElementLink nullable: true
        rank maxSize: 50
        nameElement maxSize: 255
    }

    static transients = ['name', 'instance']

    /**
     * Null if name doesn't exist
     * @return the name for NameId. Note this doesn't work for trees outside the shard
     */
    Name getName() {
        Name.get(nameId)
    }

    /**
     * Null if instance doesn't exist
     * @return the instance for InstanceId. Note this doesn't work for trees outside the shard
     */
    Instance getInstance() {
        Instance.get(instanceId)
    }

    String toString() {
        "TreeElement: $simpleName : $id"
    }
}
