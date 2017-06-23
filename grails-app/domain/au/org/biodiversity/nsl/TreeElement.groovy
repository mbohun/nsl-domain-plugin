package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType
import org.apache.commons.lang.builder.HashCodeBuilder

import java.sql.Timestamp

class TreeElement implements Serializable {

    Long treeElementId
    TreeVersion treeVersion
    TreeElement previousElement
    TreeElement parentElement

    Instance instance
    Name name
    Boolean excluded = false //is this an excluded concept

    String displayString
    String simpleName
    String treePath
    String namePath
    Map rankPath
    Map profile

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
        namePath sqlType: 'Text', index: "tree_name_path_Index"
        elementLink sqlType: 'Text'
        nameLink sqlType: 'Text'
        instanceLink sqlType: 'Text'
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
    }

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
}
