package au.org.biodiversity.nsl

import org.hibernate.SessionFactory
import org.hibernate.transform.Transformers

/**
 * This postgres-specific service returns information about the nsl session, allowing us to verify what databases things are running against at run time
 * @author ibis
 */

public class PostgresInfoService {
	SessionFactory sessionFactory_nsl
	
	public static class ConnectionInfo {
		String database
		String schema
		String currentUser
		String sessionUser
		String clientAddr
		Integer clientPort
		String serverAddr
		Integer serverPort
		Integer pid
		String version
		
		public String toString() {
			"Connected to ${currentUser}@${schema}.${database} at ${serverAddr}:${serverPort} as ${sessionUser} at ${clientAddr}:${clientPort}"
		}
	}
	
	ConnectionInfo getConnectionInfo() {
		sessionFactory_nsl.currentSession.createSQLQuery("""
			select 
					current_database() as "database",
					current_schema() as "schema", 
					current_user as "currentUser", 
					session_user as "sessionUser",
					inet_client_addr() || '' as "clientAddr", 
					inet_client_port() as "clientPort",
					inet_server_addr() || '' as "serverAddr", 
					inet_server_port() as "serverPort",
					pg_backend_pid() as "pid", 
					version() as "version"
			""").with {
			
			setResultTransformer(Transformers.aliasToBean(ConnectionInfo.class))
			uniqueResult()
		}
	}
}
