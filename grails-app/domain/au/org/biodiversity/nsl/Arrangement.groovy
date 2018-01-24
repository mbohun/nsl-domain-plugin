/*
    Copyright 2015 Australian National Botanic Gardens

    This file is part of NSL-domain-plugin.

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
    of the License at http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
package au.org.biodiversity.nsl

@Deprecated
class Arrangement {
    Namespace namespace
    ArrangementType arrangementType
    String label
    String title
    String description
    String owner
    Boolean shared
    Node node
    Arrangement baseArrangement

    String synthetic  //todo make this a boolean

    static hasMany = [
            nodes: Node
    ]

    static mappedBy = [
            nodes: 'root'
    ]

    static mapping = {
        datasource 'nsl'
        table 'tree_arrangement'
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        arrangementType column: 'tree_type', sqlType: 'bpchar', length: 1
        namespace index: 'tree_arrangement_label'
        label index: 'tree_arrangement_label'
        synthetic column: 'is_synthetic', sqlType: 'bpchar', length: 1
        node index: 'tree_arrangement_node'
    }

    static constraints = {
        namespace nullable: true //
        node nullable: true // this is needed for chicken-and-egg reasons.
        label maxSize: 50, nullable: true // some tree roots are synthetic and have no label
        title maxSize: 50, nullable: true
        owner nullable: true //
        shared nullable: true //
        description maxSize: 255, nullable: true
        baseArrangement nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        Arrangement that = (Arrangement) o

        if (arrangementType != that.arrangementType) return false
        if (baseArrangement != that.baseArrangement) return false
        if (description != that.description) return false
        if (id != that.id) return false
        if (label != that.label) return false
        if (namespace != that.namespace) return false
        if (node != that.node) return false
        if (owner != that.owner) return false
        if (shared != that.shared) return false
        if (synthetic != that.synthetic) return false
        if (title != that.title) return false

        return true
    }

    int hashCode() {
        int result
        result = (namespace != null ? namespace.hashCode() : 0)
        result = 31 * result + (arrangementType != null ? arrangementType.hashCode() : 0)
        result = 31 * result + (label != null ? label.hashCode() : 0)
        result = 31 * result + (title != null ? title.hashCode() : 0)
        result = 31 * result + (description != null ? description.hashCode() : 0)
        result = 31 * result + (owner != null ? owner.hashCode() : 0)
        result = 31 * result + (shared != null ? shared.hashCode() : 0)
        result = 31 * result + (synthetic != null ? synthetic.hashCode() : 0)
        result = 31 * result + (id != null ? id.hashCode() : 0)
        return result
    }
}
