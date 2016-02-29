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

class Arrangement {
	Namespace namespace
	ArrangementType arrangementType
	String label
	String title
	String description
	String owner
	Node node
	Node workingRoot

	String synthetic  //todo make this a boolean

	static mapping = {
		datasource 'nsl'
		table 'tree_arrangement'
		id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
		version column: 'lock_version', defaultValue: "0"

		arrangementType column: 'tree_type', sqlType: 'bpchar', length: 1
		namespace index: 'tree_arrangement_label'
		label index: 'tree_arrangement_label'
		synthetic column: 'is_synthetic', sqlType: 'bpchar', length: 1
		node index: 'tree_arrangement_node'
		workingRoot index: 'tree_arrangement_working_root'
	}

	static constraints = {
		namespace nullable: true //
		node nullable: true // this is needed for chicken-and-egg reasons.
		label maxSize: 50, nullable: true // some tree roots are synthetic and have no label
		title maxSize: 50, nullable: true
		description maxSize: 255,  nullable: true
		workingRoot nullable: true
	}
}
