package au.org.biodiversity.nsl

/**
 * This maps an incoming ID to an NSL destination id. It relies on three pieces of information to uniquely identify the
 * resource we're looking for, namely:
 *  <ul>
 *      <li>namespace - the (source) namespace, e.g. APNI or AMANI</li>
 *      <li>system - the source system, e.g. AUTHOR, or NSL-AUTHOR</li>
 *      <li>fromId - the source ID (a number)</li>
 *  </ul>
 *
 * because the NSL currently has unique IDs, the combination of fromId and ID should be unique.
 */
class IdMapper {

    Namespace namespace //source namespace of the data e.g. APNI
    String system //system the fromId is from e.g. AUTHOR
    Long fromId //The incoming Id
    Long toId

    static mapping = {
        datasource 'nsl'

        version false

        namespace index: 'id_mapper_from_Index'
        system index: 'id_mapper_from_Index'
        fromId index: 'id_mapper_from_Index'
    }

    static constraints = {
        fromId unique: 'toId'
        toId nullable: true
        system inList: [
                'AUTHOR',
                'PLANT_NAME_REFERENCE',
                'REFERENCE',
                'PLANT_NAME',
                'AUTHOR_REFERENCE',
                'PUBLICATION',
                'NSL_AUTHOR',
                'NSL_INSTANCE',
                'NSL_NAME',
                'NSL_REFERENCE'
        ]
    }
}
