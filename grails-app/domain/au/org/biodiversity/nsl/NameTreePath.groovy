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

    static transients = ['namesInBranch', 'namePathIds']

    Arrangement tree
    String nameIdPath  //String of name ids separated by dots
    //eg: 54717.224706.223519.214954.217043.214991.54582.75899
    String namePath    //String of canonical simple name separated by ' > '
    //eg: Plantae.Charophyta.Equisetopsida.Magnoliidae.Rosanae.Fabales.Fabaceae.Lablab
    String rankPath    //String of name rank names separated by ' > '
    //eg: Regnum:Plantae>Division:Charophyta>Classis:Equisetopsida>Subclassis:Magnoliidae>Superordo:Rosanae>Ordo:Fabales>Familia:Fabaceae>Genus:Lablab
    NameTreePath next
    NameTreePath parent
    Long inserted
    Name name
    Name family       //The family this name belongs to according to this tree NSL-1818

    static belongsTo = [Name]

    static mapping = {
        datasource 'nsl'
        id generator: 'native', params: [sequence: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"
        nameIdPath index: 'name_tree_path_path_index', sqlType: 'TEXT'
        namePath sqlType: 'TEXT'
        rankPath sqlType: 'TEXT'
        name index: 'name_tree_path_name_index,name_tree_path_treename_index'
        tree index: 'name_tree_path_treename_index'
        family index: 'name_tree_path_family_index'
    }

    static constraints = {
        next nullable: true
        parent nullable: true
        family nullable: true
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

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        NameTreePath that = (NameTreePath) o

        if (inserted != that.inserted) return false
        if (name != that.name) return false
        if (nameIdPath != that.nameIdPath) return false
        if (namePath != that.namePath) return false
        if (next != that.next) return false
        if (parent != that.parent) return false
        if (rankPath != that.rankPath) return false
        if (tree != that.tree) return false

        return true
    }

    int hashCode() {
        int result
        result = tree.hashCode()
        result = 31 * result + nameIdPath.hashCode()
        result = 31 * result + namePath.hashCode()
        result = 31 * result + rankPath.hashCode()
        result = 31 * result + (next != null ? next.hashCode() : 0)
        result = 31 * result + (parent != null ? parent.hashCode() : 0)
        result = 31 * result + inserted.hashCode()
        result = 31 * result + name.hashCode()
        return result
    }
}
