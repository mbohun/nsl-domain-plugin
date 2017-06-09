package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType
import org.apache.commons.lang.builder.HashCodeBuilder

import java.sql.Timestamp

class TreeElement implements Serializable {

    Long treeElementId
    TreeVersion treeVersion
    Instance instance
    Name name
    TreeElement previousElement
    TreeElement parentElement
    String displayString
    String simpleName
    String treePath
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
        simpleName sqlType: 'Text'
        treePath sqlType: 'Text'
        elementLink sqlType: 'Text'
        nameLink sqlType: 'Text'
        instanceLink sqlType: 'Text'
        rankPath type: JsonbMapType
        profile type: JsonbMapType

        columns {
            parentElement {
                column name: 'parentVersionId'
                column name: 'parentElementId'
            }
            previousElement {
                column name: 'previousVersionId'
                column name: 'previousElementId'
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
