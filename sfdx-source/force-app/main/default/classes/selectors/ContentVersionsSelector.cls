/**
 * @author DoorDash
 * @description Selector class for the ContentVersion object.
 **/
public inherited sharing class ContentVersionsSelector extends fflib_SObjectSelector implements IContentVersionsSelector {
    /**
     * @description default constructor for the ContentVersion Selector class
     * @return IContentVersionsSelector - interface of IContentVersionsSelector
     */
    public static IContentVersionsSelector newInstance() {
        return (IContentVersionsSelector) Application.Selector.newInstance(
            ContentVersion.SObjectType
        );
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.SObjectType;
    }

    /**
     * @description This method is for getting the fields on ContentVersion object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentVersion.Id,
            ContentVersion.CreatedById,
            ContentVersion.CreatedDate,
            ContentVersion.FileType,
            ContentVersion.LastModifiedDate,
            ContentVersion.LastModifiedById,
            ContentVersion.ContentDocumentId,
            ContentVersion.Description,
            ContentVersion.IsLatest,
            ContentVersion.Title,
            ContentVersion.VersionNumber,
            ContentVersion.VersionData
        };
    }

    /**
     * @description Returns a List of ContentVersions by their IDs
     * @param idSet - Set of ContentVersion IDs
     * @return List<ContentVersion>
     */
    public List<ContentVersion> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN: idSet');
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a List of ContentVersions by ContentDocumentId
     * @param documentIds - ContentDocumentIds
     * @return List<ContentVersion>
     **/
    public List<ContentVersion> selectByContentDocumentIds(Set<Id> documentIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ContentDocumentId IN :documentIds');
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a List of the latest ContentVersions by ContentDocumentId
     * @param documentIds - ContentDocumentIds
     * @return List<ContentVersion>
     **/
    public List<ContentVersion> selectLatestByContentDocumentIds(Set<Id> documentIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ContentDocumentId IN :documentIds');
        query.setCondition('IsLatest = true');
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries Content Versions along with Fraud Document details
     * based on passed Store Account Ids.
     * @JIRA# LEM-16642
     * @param relatedStoreIds
     * @return List<ContentVersion>
     */
    public List<ContentVersion> selectByRelatedStoreIds(Set<Id> relatedStoreIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Related_To_Id__c')
            .selectField('Title')
            .selectField('VersionNumber')
            .selectField('Mx_Fraud_Document__r.CreatedDate')
            .selectField('Mx_Fraud_Document__r.LastModifiedDate')
            .selectField('Mx_Fraud_Document__r.Mx_Document_Type__c')
            .selectField('Mx_Fraud_Document__r.Mx_Document_Verification_Status__c')
            .selectField('Mx_Fraud_Document__r.Mx_Document_Verification_Notes__c')
            .selectField('Mx_Fraud_Document__r.Mx_Store_Id__c')
            .setCondition(
                'Related_To_Id__c IN :relatedStoreIds AND Mx_Fraud_Document__r.Mx_Store_Id__c IN :relatedStoreIds'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }
}