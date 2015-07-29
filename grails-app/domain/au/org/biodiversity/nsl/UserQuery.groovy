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

import java.sql.Clob
import java.sql.Timestamp

class UserQuery {

    String searchModel
    String searchTerms
    Clob searchResult
    Timestamp searchStartedAt
    Timestamp searchFinishedAt
    String searchInfo
    BigDecimal recordCount
    Boolean queryCompleted
    Boolean queryStarted

    Timestamp createdAt
    Timestamp updatedAt

    Boolean trash = false

    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        trash defaultvalue: "false"
        searchStartedAt sqlType: 'timestamp with time zone'
        searchFinishedAt sqlType: 'timestamp with time zone'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        searchModel nullable: true, maxSize: 4000
        searchTerms nullable: true, maxSize: 4000
        searchResult nullable: true
        searchStartedAt nullable: true
        searchFinishedAt nullable: true
        searchInfo nullable: true, maxSize: 500
    }
}
