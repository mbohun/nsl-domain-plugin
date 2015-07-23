package au.org.biodiversity.nsl

import java.sql.Timestamp

class Comment {

    String text
    Name name
    Instance instance
    Author author
    Reference reference

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    static belongsTo = [Name, Instance, Reference, Author]


    static mapping = {
        datasource 'nsl'

        id generator: 'native', params: [sequence: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"
        version column: 'lock_version', defaultValue: "0"
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
        text sqlType: 'text'

        name index: 'Comment_name_Index'
        instance index: 'Comment_instance_Index'
        author index: 'Comment_author_Index'
        reference index: 'Comment_reference_Index'
    }

    static constraints = {
        name nullable: true
        instance nullable: true
        author nullable: true
        reference nullable: true
        updatedBy maxSize: 50
        createdBy maxSize: 50
    }

    @Override
    String toString() {
        def entity = name ?: instance ?: author ?: reference ?: 'nothing'
        "Comment $id: ${text} (${updatedBy} @ ${updatedAt}) on $entity"
    }
}
