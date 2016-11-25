package au.org.biodiversity.nsl

/**
 * A uri that may be used as a value node in a tree.
 * The main purpose of this class is to generate picklists.
 * Created by ibis on 17/11/16.
 */
class ValueNodeUri {
    Arrangement root;
    UriNs linkUriNsPart;
    String linkUriIdPart;
    UriNs nodeUriNsPart;
    String nodeUriIdPart;

    String label;
    String title;
    String description;

    int sortOrder = 0;

    boolean isMultiValued;
    boolean isResource;

    static belongsTo = [
            root         : Arrangement,
            linkUriNsPart: UriNs,
            nodeUriNsPart: UriNs
    ]

    static mapping = {
        datasource 'nsl'
        table 'tree_value_uri'
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultvalue: 0
        isMultiValued defaultvalue: false
        isResource defaultvalue: false

        root index: 'by_root_id,link_uri_index,node_uri_index'
        linkUriNsPart index: 'link_uri_index'
        linkUriIdPart index: 'link_uri_index'
        nodeUriNsPart index: 'node_uri_index'
        nodeUriIdPart index: 'node_uri_index'
    }

    static constraints = {
        root nullable: false
        linkUriNsPart nullable: false
        linkUriIdPart nullable: false
        nodeUriNsPart nullable: false
        nodeUriIdPart nullable: false
        label nullable: false, maxSize: 20
        title nullable: false, maxSize: 50
        description nullable: true, maxSize: 2048
        sortOrder nullable: false
        isMultiValued nullable: false
        isResource nullable: false

    }

}



