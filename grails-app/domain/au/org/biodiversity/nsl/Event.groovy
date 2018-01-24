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

import java.sql.Timestamp

@Deprecated
class Event {
    Namespace namespace
    Timestamp timeStamp
    String authUser
    String note

    static mapping = {
        datasource 'nsl'
        table 'tree_event'
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        authUser maxSize: 50
        note maxSize: 255
        timeStamp sqlType: 'timestamp with time zone'
    }


    static constraints = {
        namespace nullable: true //
        note nullable: true  //
    }
}
