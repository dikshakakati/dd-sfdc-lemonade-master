/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Selector Class for Account Relationships Object
 */
public inherited sharing class AccountRelationshipsSelector extends fflib_SObjectSelector implements IAccountRelationshipsSelector {
    private static final String RELATIONSHIP_STATUS_ACTIVE = 'Active';
    /**
     * @description Default Constructor for the Account Relationships Selector Class
     * @return IAccountRelationshipsSelector - Interface of Account Relationships
     */
    public static IAccountRelationshipsSelector newInstance() {
        return (IAccountRelationshipsSelector) Application.Selector.newInstance(
            Account_Relationship__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting the fields on Account Relationship object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Relationship__c.Id,
            Account_Relationship__c.Name,
            Account_Relationship__c.Account__c,
            Account_Relationship__c.Related_Account__c,
            Account_Relationship__c.Relationship_Status__c,
            Account_Relationship__c.End_Date__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account_Relationship__c.SObjectType;
    }

    /**
     * @description This method is used for getting active Account Relationships with past End Dates
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectActiveRelationshipsWithPastEndDates() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'End_Date__c < TODAY AND Relationship_Status__c = :RELATIONSHIP_STATUS_ACTIVE'
        );
        query.addOrdering('Account__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description Select all Account Relationship with External Id present in the List
     * @param externalIds
     * @return List of Account Relationship records
     */
    public List<Account_Relationship__c> selectRelationshipsWithExternalIds(
        Set<String> externalIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_Id__c IN :externalIds');
        query.selectField('External_Id__c');
        return (List<Account_Relationship__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Select all Acount Relationships with External Ids
     * @return List<Account_Relationship__c>
     */
    public List<Account_Relationship__c> selectAllRelationshipsWithExternalIds() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_Id__c != NULL');
        query.selectField('External_Id__c');
        return (List<Account_Relationship__c>) Database.query(query.toSOQL());
    }
}