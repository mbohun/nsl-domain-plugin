package au.org.biodiversity.nsl

class Link implements Comparable<Link> {
	/* note what this is saying about the data model - 
	 * a "node" *is* the node object and 
	 * its links to its subnodes.
	 */

	static belongsTo = [supernode:Node]
	static transients = ['typeUri']

	Node subnode

	UriNs typeUriNsPart
	String typeUriIdPart
	int linkSeq
	VersioningMethod versioningMethod
	boolean synthetic

	static mapping = {
		datasource 'nsl'
		table 'tree_link'
		id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
		version column: 'lock_version', defaultValue: "0"

		versioningMethod column: 'versioning_method', sqlType: 'bpchar', length: 1
		synthetic column: 'is_synthetic', sqlType: 'bpchar', length: 1,  type: 'yes_no'
		subnode column: 'subnode_id', index: 'tree_link_subnode'
		supernode column: 'supernode_id', index: 'tree_link_supernode'
	}

	static constraints = {
		typeUriNsPart nullable:false
		typeUriIdPart maxSize: 255, nullable: true
	}

	public int compareTo(Link o) {
		if(!supernode.equals(o.supernode)) {
			return supernode.compareTo(o.supernode)
		}
		else {
			return linkSeq - o.linkSeq
		}
	}
}
