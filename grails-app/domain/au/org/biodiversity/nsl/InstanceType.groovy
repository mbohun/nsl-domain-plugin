package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = 'name')
class InstanceType {

    String name
    Boolean primaryInstance = false
    Boolean secondaryInstance = false
    Boolean relationship = false
    Boolean protologue = false
    Boolean taxonomic = false
    Boolean nomenclatural = false
    Boolean synonym = false
    Boolean proParte = false
    Boolean doubtful = false
    Boolean misapplied = false
    Boolean standalone = false
    Boolean unsourced = false
    Boolean citing = false
    Boolean deprecated = false
    Integer sortOrder = 0
    String rdfId
    String descriptionHtml

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        primaryInstance defaultvalue: "false"
        secondaryInstance defaultvalue: "false"
        relationship defaultvalue: "false"
        protologue defaultvalue: "false"
        taxonomic defaultvalue: "false"
        nomenclatural defaultvalue: "false"
        synonym defaultvalue: "false"
        proParte defaultvalue: "false"
        doubtful defaultvalue: "false"
        misapplied defaultvalue: "false"
        standalone defaultvalue: "false"
        unsourced defaultvalue: "false"
        citing defaultvalue: "false"
        deprecated defaultvalue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
