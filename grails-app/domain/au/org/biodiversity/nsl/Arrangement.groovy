package au.org.biodiversity.nsl

class Arrangement {
	ArrangementType arrangementType
	String label
	String title
	String description
	Node node

	String synthetic  //todo make this a boolean

	static mapping = {
		datasource 'nsl'
		table 'tree_arrangement'
		id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
		version column: 'lock_version', defaultValue: "0"

		arrangementType column: 'tree_type', sqlType: 'bpchar', length: 1
		label index: 'tree_arrangement_label', unique: true, nullable: true
		synthetic column: 'is_synthetic', sqlType: 'bpchar', length: 1
		node index: 'tree_arrangement_node'
	}

	static constraints = {
		node nullable: true // this is needed for chicken-and-egg reasons.
		label maxSize: 50, nullable: true // some tree roots are synthetic and have no label
		title maxSize: 50, nullable: true
		description maxSize: 255,  nullable: true
	}
}
