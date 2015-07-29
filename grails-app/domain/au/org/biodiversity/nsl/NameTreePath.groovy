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

    static transients = ['namesInBranch', 'pathIds']

    Arrangement tree
    String treePath    //NameTreePath path string of NameTreePath ids
    String path        //Name path string of name ids
    NameTreePath next
    NameTreePath parent
    Long inserted
    Name name

    static belongsTo = [Name]

    static mapping = {
        datasource 'nsl'
        id column: "id", generator: "assigned"
        path index: 'name_tree_path_path_index'
        treePath index: 'name_tree_path_treepath_index'
        name index: 'name_tree_path_name_index'
    }

    static constraints = {
        next nullable: true
        parent nullable: true
        treePath maxSize: 4000
        path maxSize: 4000
    }

    public List<Long> pathIds() {
        List<Long> ids = path.split(/\./).collect{ String id ->
            id.toLong()
        }
        return ids
    }

    public List<Name> namesInBranch() {
        List<Long> ids = pathIds()
        //noinspection UnnecessaryQualifiedReference
        return Name.getAll(ids)
    }
}
