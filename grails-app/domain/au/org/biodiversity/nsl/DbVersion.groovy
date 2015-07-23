package au.org.biodiversity.nsl

/**
 * There should only ever be a single db_version record in the database.
 * This record is updated to the current version when an update script is run to update the data model in the database.
 * Versions are simple serial Integers e.g 1,2,3,4... etc
 */
class DbVersion {

    Integer version

    static mapping = {
        datasource 'nsl'
    }

    static constraints = {
    }
}
