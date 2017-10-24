package au.org.biodiversity.nsl

class TreeVersionElement {

    TreeElement treeElement
    TreeVersion treeVersion
    Long taxonId

    String elementLink
    String taxonLink

    static belongsTo = [TreeVersion, TreeElement]

    static mapping = {
        datasource 'nsl'
        id generator: 'assigned', name: 'elementLink', type: 'string'
        version false

        elementLink sqlType: 'Text', index: 'tree_version_element_link_index'
        taxonLink sqlType: 'Text', index: 'tree_version_element_taxon_link_index'
        treeElement index: 'tree_version_element_element_index'
        treeVersion index: 'tree_version_element_version_index'
        taxonId index: 'tree_version_element_taxon_id_index'
    }

    static constraints = {
    }

    String toString() {
        "TreeVersionElement $treeElement.simpleName v: $treeVersion.id e:$treeElement.id ($elementLink) t: $taxonId"
    }
}