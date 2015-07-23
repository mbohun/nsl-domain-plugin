package au.org.biodiversity.nsl

class Notification {

    String message
    Long objectId

    static mapping = {
        datasource 'nsl'
    }

    static constraints = {
        objectId nullable: true
    }
}
