/**
 * @author Deloitte
 * @date 08/04/2022
 * @description Selector Class for ContentDocumentLink Object
 */
public inherited sharing class ContentDocumentLinkSelector extends fflib_SObjectSelector implements IContentDocumentLinkSelector {
    static final String SNOTE = 'SNOTE';
    static final String COMPLETED_FILE_SEARCH_STRING = '%completed%';
    static final String ENTITY_TYPE = 'SBQQ__Quote__c';
    static final String IO_TEMPLATE_NAME = 'Insertion_Order_for_%';
    static final String PDF = '%.pdf';

    /**
     * @description Default constructor for the ContentDocumentLink Selector class
     * @return IContentDocumentLinkSelector - interface of IContentDocumentLinkSelector
     */
    public static IContentDocumentLinkSelector newInstance() {
        return (IContentDocumentLinkSelector) Application.Selector.newInstance(
            ContentDocumentLink.SObjectType
        );
    }
    /**
     * @description This method is used for getting the fields on Opportunity object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentDocumentLink.Id,
            ContentDocumentLink.LinkedEntityId
        };
    }

    /**
     * @description This method is to get object type
     * @return ContentDocumentLink Object
     */
    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.SObjectType;
    }

    /**
     * @description This method is to get ContentDocumentLink Ids
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    public List<ContentDocumentLink> selectById(Set<Id> setIds) {
        return (List<ContentDocumentLink>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is to get ContentDocumentLink based on Opportunity Ids
     * @param setIds Set of Ids
     * @param numberOfDays
     * @return list of ContentDocumentLink records
     */
    public List<ContentDocumentLink> selectNotesByLinkedEntityAndLastModifiedDate(
        Set<Id> setIds,
        Integer numberOfDays
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'LinkedEntityId IN :setIds AND ContentDocument.lastmodifieddate >= ' +
            'LAST_N_DAYS :' +
            numberOfDays +
            ' AND ContentDocument.FileType = :SNOTE'
        );
        return (List<ContentDocumentLink>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is to get ContentDocumentLink data for files
     * with a Title that starts with Insertion_order_for_quotename and linked entity is quote
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    public List<ContentDocumentLink> selectDraftIOTemplates(Set<Id> setIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('ContentDocumentId');
        query.selectField('ContentDocument.Title');
        query.selectField('LinkedEntity.Name');
        query.selectField('LinkedEntityId');
        query.setCondition(
            'LinkedEntityId IN :setIds ' +
            'AND ContentDocument.Title LIKE :IO_TEMPLATE_NAME ' +
            'AND (NOT ContentDocument.Title LIKE :COMPLETED_FILE_SEARCH_STRING) ' +
            'AND ContentDocument.Title LIKE :PDF'
        );
        return (List<ContentDocumentLink>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is to get ContentDocumentLink data for files
     * with a Title that ends in completed.pdf linked to a quote in the Set of Ids
     * @param setIds Set of Ids
     * @return list of ContentDocumentLink records
     */
    public List<ContentDocumentLink> selectCompletedTitlesByLinkedEntity(Set<Id> setIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('ContentDocumentId');
        query.selectField('ContentDocument.Title');

        query.setCondition(
            'LinkedEntityId IN :setIds AND ContentDocument.Title LIKE :COMPLETED_FILE_SEARCH_STRING'
        );
        return (List<ContentDocumentLink>) Database.query(query.toSOQL());
    }
}