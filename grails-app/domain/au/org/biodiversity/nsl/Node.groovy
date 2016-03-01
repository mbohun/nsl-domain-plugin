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

class Node {
    /* if we were using hibernate subclasses, this value would be a discriminator */
    NodeInternalType internalType

    Node prev
    Node next

    Arrangement root

    Name name;
    Instance instance;

    UriNs typeUriNsPart
    String typeUriIdPart
    UriNs nameUriNsPart
    String nameUriIdPart
    UriNs taxonUriNsPart
    String taxonUriIdPart
    UriNs resourceUriNsPart
    String resourceUriIdPart

    String literal

    Event checkedInAt
    Event replacedAt

    boolean synthetic

    static hasMany = [
            subLink : Link,
            supLink : Link,
            branches: Node,
            merges  : Node
    ]

    static mappedBy = [
            subLink : 'supernode',
            supLink : 'subnode',
            branches: 'prev',
            merges  : 'next'
    ]


    static mapping = {
        datasource 'nsl'
        table 'tree_node'
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        prev column: 'prev_node_id', index: 'tree_node_prev'
        next column: 'next_node_id', index: 'tree_node_next'
        root column: 'tree_arrangement_id', index: 'idx_tree_node_name_in,idx_tree_node_taxon_in,idx_tree_node_resource_in,idx_tree_node_name_id_in,idx_tree_node_instance_id_in'

        name index: 'idx_tree_node_name_id,idx_tree_node_name_id_in'
        instance index: 'idx_tree_node_instance_id,idx_tree_node_instance_id_in'

        // not indexing the type because there will be too many nodes of a given type to make it a useful search
        nameUriNsPart index: 'idx_tree_node_name,idx_tree_node_name_in'
        nameUriIdPart index: 'idx_tree_node_name,idx_tree_node_name_in'
        taxonUriNsPart index: 'idx_tree_node_taxon,idx_tree_node_taxon_in'
        taxonUriIdPart index: 'idx_tree_node_taxon,idx_tree_node_taxon_in'
        resourceUriNsPart index: 'idx_tree_node_resource,idx_tree_node_resource_in'
        resourceUriIdPart index: 'idx_tree_node_resource,idx_tree_node_resource_in'
        literal index: 'idx_tree_node_literal'


        internalType column: 'internal_type', sqlType: 'bpchar', length: 1
        synthetic column: 'is_synthetic', sqlType: 'bpchar', length: 1, type: 'yes_no'
    }

    static constraints = {
        internalType nullable: false
        prev nullable: true
        next nullable: true
        name nullable: true
        instance nullable: true
        typeUriNsPart nullable: false
        typeUriIdPart maxSize: 255, nullable: true
        nameUriNsPart nullable: true
        nameUriIdPart maxSize: 255, nullable: true
        taxonUriNsPart nullable: true
        taxonUriIdPart maxSize: 255, nullable: true
        resourceUriNsPart nullable: true
        resourceUriIdPart maxSize: 255, nullable: true
        literal nullable: true, maxSize: 4096
        checkedInAt nullable: true
        replacedAt nullable: true
        literal nullable: true
    }

    static transients = ['namespace']

    Namespace namespace() {
        return root.namespace
    }
}
