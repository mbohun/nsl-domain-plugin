package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString
class Namespace {

    String name
    String rdfId
    String descriptionHtml

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        authors joinTable: "AUTHOR_NAMESPACE"
        names joinTable: "NAME_NAMESPACE"
        references joinTable: "REF_NAMESPACE"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
