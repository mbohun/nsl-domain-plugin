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
