package au.org.biodiversity.nsl

class TreeVersionElement {

    TreeElement treeElement
    TreeVersion treeVersion

    String elementLink

    static belongsTo = [TreeVersion, TreeElement]

    static mapping = {
        datasource 'nsl'
        id generator: 'assigned', name: 'elementLink', type: 'string'
        version false

        elementLink sqlType: 'Text', index: 'tree_version_element_link_index'
        treeElement index: 'tree_version_element_element_index'
        treeVersion index: 'tree_version_element_version_index'
    }

    static constraints = {
    }
}
