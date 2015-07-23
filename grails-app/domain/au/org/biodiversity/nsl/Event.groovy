package au.org.biodiversity.nsl

import java.sql.Timestamp

class Event {
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


	static constraints = {  note nullable:true  }
}
