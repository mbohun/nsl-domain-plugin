package au.org.biodiversity.nsl
import spock.lang.Specification


class PostgresInfoServiceSpec extends Specification {
	PostgresInfoService postgresInfoService
	
	def "test getConnectionInfo"() {
		when:
		PostgresInfoService.ConnectionInfo info = postgresInfoService.getConnectionInfo()
		
		then:
		info
	}
}
