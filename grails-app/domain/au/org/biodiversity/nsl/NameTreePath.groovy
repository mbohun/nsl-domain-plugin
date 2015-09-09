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

/**
 * NameTreePath is a view or cache of a tree linking directly to Names. They contain the tree path from root to the current name
 * as a string of name IDs and nameTreePath ids.
 *
 * This inverts the structure of the tree as compared to the tree nodes and links and allows you to do rapid queries to
 * get the set of names under a particular name on the tree by finding all the nameTreePaths that start with this path.
 */

class NameTreePath {

    static transients = ['namesInBranch', 'namePathIds', 'nodesInBranch', 'nodePathIds']

    Arrangement tree
    String nodeIdPath  //String of nameTree Path or tree node ids separated by dots
    String nameIdPath  //String of name ids separated by dots
    String namePath    //String of canonical simple name separated by ' > '
    String rankPath    //String of name rank names separated by ' > '
    NameTreePath next
    NameTreePath parent
    Long inserted
    Name name

    static belongsTo = [Name]

    static mapping = {
        datasource 'nsl'
        id column: "id", generator: "assigned"
        nameIdPath index: 'name_tree_path_path_index', sqlType: 'TEXT'
        nodeIdPath index: 'name_tree_path_treepath_index', sqlType: 'TEXT'
        namePath sqlType: 'TEXT'
        rankPath sqlType: 'TEXT'
        name index: 'name_tree_path_name_index'
    }

    static constraints = {
        next nullable: true
        parent nullable: true
    }

    public List<Long> namePathIds() {
        List<Long> ids = nameIdPath.split(/\./).collect{ String id ->
            id.toLong()
        }
        return ids
    }

    public List<Name> namesInBranch() {
        List<Long> ids = namePathIds()
        //noinspection UnnecessaryQualifiedReference,GroovyAssignabilityCheck
        return Name.getAll(ids)
    }

    public List<Long> nodePathIds() {
        List<Long> ids = nodeIdPath.split(/\./).collect{ String id ->
            id.toLong()
        }
        return ids
    }

    public List<Node> nodesInBranch() {
        List<Long> ids = nodePathIds()
        //noinspection UnnecessaryQualifiedReference,GroovyAssignabilityCheck
        return Node.getAll(ids)
    }
}
