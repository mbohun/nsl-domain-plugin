package net.kaleidos.hibernate.usertype

import groovy.transform.CompileStatic

@CompileStatic
class JsonbListType extends JsonListType {

    static int SQLTYPE = 90052

    @Override
    int[] sqlTypes() {
        SQLTYPE as int[]
    }
}
