package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType
import org.apache.commons.lang.builder.HashCodeBuilder

import java.sql.Timestamp

class TreeElement implements Serializable {

    Long treeElementId
    TreeVersion treeVersion
    TreeElement previousElement
    TreeElement parentElement

    Long instanceId          //unconstrained FK to the instance - depends on the shard
    Long nameId              //unconstrained FK to the name - depends on the shard
    Boolean excluded = false //is this an excluded concept

    String displayString
    String simpleName
    String treePath
    String namePath
    String names            //a pipe separated list of name and synonyms
    String sourceShard      //where the taxon comes from
    Map synonyms
    Map rankPath
    Map profile

    String sourceElementLink //Link to the source tree element for composed trees
    String elementLink
    String nameLink
    String instanceLink

    String updatedBy
    Timestamp updatedAt

    static belongsTo = [TreeVersion]

    static mapping = {
        datasource 'nsl'

        id composite: ['treeVersion', 'treeElementId']
        version column: 'lock_version', defaultValue: "0"

        updatedAt sqlType: 'timestamp with time zone'
        displayString sqlType: 'Text'
        simpleName sqlType: 'Text', index: "tree_simple_name_Index"
        treePath sqlType: 'Text'
        namePath sqlType: 'Text'
        names sqlType: 'Text'
        sourceShard sqlType: 'Text'
        elementLink sqlType: 'Text'
        nameLink sqlType: 'Text'
        instanceLink sqlType: 'Text'
        sourceElementLink sqlType: 'Text'
        synonyms type: JsonbMapType
        rankPath type: JsonbMapType
        profile type: JsonbMapType
        excluded defaultValue: false

        columns {
            parentElement {
                column name: 'parent_Version_Id'
                column name: 'parent_Element_Id'
            }
            previousElement {
                column name: 'previous_Version_Id'
                column name: 'previous_Element_Id'
            }
        }
    }

    static constraints = {
        treeVersion nullable: false
        previousElement nullable: true
        parentElement nullable: true
        sourceElementLink nullable: true
    }

    static transients = ['name', 'instance']

    boolean equals(other) {
        if (!(other instanceof TreeElement)) {
            return false
        }

        other.treeVersion.id == treeVersion.id && other.treeElementId == treeElementId
    }

    int hashCode() {
        def builder = new HashCodeBuilder()
        builder.append(treeVersion.id)
        builder.append(treeElementId)
        builder.toHashCode()
    }

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
}
