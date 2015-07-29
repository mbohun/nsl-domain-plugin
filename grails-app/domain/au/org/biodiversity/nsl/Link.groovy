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
