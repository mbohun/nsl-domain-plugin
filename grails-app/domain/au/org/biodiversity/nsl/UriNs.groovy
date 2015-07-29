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

class UriNs {
	String uri
	String label
	String title
	String description
	UriNs ownerUriNsPart
	String ownerUriIdPart

	Long idMapperNamespaceId
	String idMapperSystem

	static mapping = {
		datasource 'nsl'
		table 'tree_uri_ns'
		id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
		version column: 'lock_version', defaultValue: "0"

		label index: 'idx_tree_uri_ns_label'
		uri index: 'idx_tree_uri_ns_uri'
	}

	static constraints = {
		uri maxSize: 255, unique: true, nullable: true
		label maxSize: 20, unique: true
		title maxSize: 255, nullable: true
		description maxSize: 255, nullable: true
		ownerUriNsPart nullable: true
		ownerUriIdPart maxSize: 255, nullable: true
		idMapperNamespaceId nullable: true
		idMapperSystem nullable:true, maxSize: 255
	}

	/** Never returns null */

	public String getUri() {
		return this.uri ?: ''
	}
}
