/**
 * @author Deloitte
 * @date 19/05/2022
 * @description Interface for Account Relationship Selector class
 */
public interface IAccountRelationshipsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting active Account Relationships with past End Dates
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectActiveRelationshipsWithPastEndDates();

    /**
     * @description Select all Account Relationship with External Id present in the List
     * @param externalIds
     * @return List of Account Relationship records
     */
    List<Account_Relationship__c> selectRelationshipsWithExternalIds(Set<String> externalIds);

    /**
     * @description Select all Acount Relationships with External Ids
     * @return List<Account_Relationship__c>
     */
    List<Account_Relationship__c> selectAllRelationshipsWithExternalIds();
}