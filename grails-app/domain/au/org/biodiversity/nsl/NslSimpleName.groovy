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

class NslSimpleName implements Serializable {
    //id should be the name id in NSL

    String name             //name.simpleName
    String taxonName        //name.fullName
    String nameElement      //name element
    String cultivarName     //name element if it's a cultivar
    String simpleNameHtml   //name.simplenNameHtml
    String fullNameHtml     //name.fullNameHtml
    String nameTypeName     //name.nameType.name
    String basionym         //basionym instance name.fullName
    String replacedSynonym  //Replaced synonym instance name

    NameType nameType       //name.nameType
    Boolean homonym
    Boolean autonym
    Boolean hybrid
    Boolean cultivar
    Boolean formula
    Boolean scientific

    String authority        //author string from name
    String baseNameAuthor
    String exBaseNameAuthor
    String author
    String exAuthor
    String sanctioningAuthor

    String rank             //name.nameRank.name
    NameRank nameRank       //name.nameRank
    Integer rankSortOrder   //name.sortOrder
    String rankAbbrev       //rank.abbrev

    String classifications  //list of trees this name is in
    Boolean apni            //is it in APNI Y/N

    String protoCitation    //protologue reference citation
    Instance protoInstance  //protologue instance
    Short protoYear         //year of the protologue instance reference
    String nomStat          //name.nameStatus.name
    NameStatus nameStatus
    Boolean nomIlleg
    Boolean nomInval

    Long dupOfId

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    //tree related
    Name parentNsl
    Name secondParentNsl
    Name familyNsl          //name/simplename id of the family of this name
    Name genusNsl           //name/simplename id of the genus of this name
    Name speciesNsl         //name/simplename id of the species of this name

    String classis          //name element of the class this name is under
    String subclassis         //name element of the subclass this name is under
    String familia           //name element of the family this name is under
    String genus            //name element of the genus this name is under
    String species          //name element of the species this name is under
    String infraspecies     //name element of the infraspecies this name is under
    //APC
    String apcFamilia        //name element of the APC family this name is under
    Instance apcInstance
    String apcName
    String apcRelationshipType
    String apcComment
    String apcDistribution
    Boolean apcProparte
    Boolean apcExcluded

    static mapping = {
        datasource 'nsl'
        id column: "id", generator: "assigned"
        version false
        apni defaultValue: "false"
        homonym defaultValue: "false"
        autonym defaultValue: "false"
        hybrid defaultValue: "false"
        cultivar defaultValue: "false"
        formula defaultValue: "false"
        scientific defaultValue: "false"
        nomIlleg defaultValue: "false"
        nomInval defaultValue: "false"
        apcProparte defaultValue: "false"
        apcExcluded defaultValue: "false"
    }

    static constraints = {

        name maxSize: 255
        taxonName maxSize: 512
        fullNameHtml nullable: true, maxSize: 2048
        simpleNameHtml nullable: true, maxSize: 2048
        nameElement nullable: true, maxSize: 255
        cultivarName nullable: true, maxSize: 255
        basionym nullable: true, maxSize: 512
        replacedSynonym nullable: true, maxSize: 512

        nameTypeName maxSize: 255
        homonym nullable: true
        autonym nullable: true
        hybrid nullable: true
        scientific nullable: true
        nomIlleg nullable: true
        nomInval nullable: true

        authority nullable: true, maxSize: 255
        baseNameAuthor nullable: true, maxSize: 255
        exBaseNameAuthor nullable: true, maxSize: 255
        author nullable: true, maxSize: 255
        exAuthor nullable: true, maxSize: 255
        sanctioningAuthor nullable: true, maxSize: 255

        rank maxSize: 255
        rankSortOrder nullable: true
        rankAbbrev nullable: true, maxSize: 255

        classifications nullable: true
        apni nullable: true

        protoCitation nullable: true, maxSize: 512
        protoInstance nullable: true
        protoYear nullable: true
        nomStat maxSize: 255
        nomIlleg nullable: true
        nomInval nullable: true

        dupOfId nullable: true

        updatedBy nullable: true, maxSize: 255
        updatedAt nullable: true
        createdBy nullable: true, maxSize: 255
        createdAt nullable: true

        parentNsl nullable: true
        secondParentNsl nullable: true
        familyNsl nullable: true
        genusNsl nullable: true
        speciesNsl nullable: true

        classis nullable: true, maxSize: 255
        subclassis nullable: true, maxSize: 255
        apcFamilia nullable: true, maxSize: 255
        familia nullable: true, maxSize: 255
        genus nullable: true, maxSize: 255
        species nullable: true, maxSize: 255
        infraspecies nullable: true, maxSize: 255

        apcInstance nullable: true
        apcName nullable: true, maxSize: 512
        apcRelationshipType nullable: true, maxSize: 255
        apcComment nullable: true, maxSize: 4000
        apcDistribution nullable: true, maxSize: 4000
    }
}

